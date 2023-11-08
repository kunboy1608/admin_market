import 'dart:async';

import 'package:admin_market/bloc/banner_cubit.dart';
import 'package:admin_market/entity/banner.dart';
import 'package:admin_market/home/banner/banner_card.dart';
import 'package:admin_market/home/banner/banner_editor.dart';
import 'package:admin_market/service/entity/banner_service.dart';
import 'package:admin_market/service/google/firestorage_service.dart';
import 'package:admin_market/service/image_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart' hide Banner;
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _bannerStream;
  bool _isHidenFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_isHidenFloatingButton == true) {
          setState(() {
            _isHidenFloatingButton = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isHidenFloatingButton == false) {
          setState(() {
            _isHidenFloatingButton = true;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BannerService.instance.getSnapshot().then((stream) {
        _bannerStream = stream.listen((event) {
          for (var element in event.docChanges) {
            Banner b = Banner.fromMap(element.doc.data()!)..id = element.doc.id;
            // Get actually link
            if (b.imgUrl != null &&
                element.type != DocumentChangeType.removed) {
              ImageService.instance.getActuallyLink(b.imgUrl!).then((value) {
                b.actuallyLink = value;
              });
            }

            switch (element.type) {
              case DocumentChangeType.added:
              case DocumentChangeType.modified:
                context.read<BannerCubit>().addOrUpdateIfExist(b);
                break;
              case DocumentChangeType.removed:
                // Support remove useless img on Firestorage
                context.read<BannerCubit>().remove(b);
                if (b.imgUrl != null) {
                  FirestorageService.instance.delete(b.imgUrl!);
                }
                break;
              default:
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Banners Management"),
      ),
      body: BlocBuilder<BannerCubit, Map<String, Banner>>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: defPading),
          child: ListView.separated(
              controller: _scrollController,
              itemBuilder: (_, index) =>
                  BannerCard(banner: state.values.elementAt(index)),
              separatorBuilder: (_, __) => const SizedBox(
                    height: defPading,
                  ),
              itemCount: state.values.length),
        ),
      ),
      floatingActionButton: _isHidenFloatingButton
          ? null
          : FloatingActionButton(
              heroTag: 'banner_card_hero',
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const BannerEditor(),
                    ));
              },
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  @override
  void dispose() {
    debugPrint("Banner Page: dipose");
    _bannerStream.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
