import 'dart:async';

import 'package:admin_market/bloc/banner_cubit.dart';
import 'package:admin_market/entity/banner.dart';
import 'package:admin_market/home/banner/banner_card.dart';
import 'package:admin_market/home/banner/banner_editor.dart';
import 'package:admin_market/service/entity/banner_service.dart';
import 'package:admin_market/service/google/firestorage_service.dart';
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

class _BannerPageState extends State<BannerPage> {
  late ScrollController _scrollController;
  late StreamController<(DocumentChangeType, Banner)> _streamController;
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

    _streamController = StreamController<(DocumentChangeType, Banner)>();
    BannerService.instance.listenChanges(_streamController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streamController.stream.listen((event) {
        switch (event.$1) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            context.read<BannerCubit>().addOrUpdateIfExist(event.$2);
            break;
          case DocumentChangeType.removed:
            // Support remove useless img on Firestorage
            context.read<BannerCubit>().remove(event.$2);
            FirestorageService.instance.delete(event.$2.imgUrl ?? "");
            break;
          default:
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
              heroTag: 'thumbnail',
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const BannerEditor(),
                    ));
              },
              child: const Icon(Icons.add_outlined),
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streamController.close();
    super.dispose();
  }
}
