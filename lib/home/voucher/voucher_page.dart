import 'dart:async';

import 'package:admin_market/bloc/voucher_cubit.dart';
import 'package:admin_market/entity/voucher.dart';
import 'package:admin_market/home/voucher/voucher_card.dart';
import 'package:admin_market/home/voucher/voucher_editor.dart';
import 'package:admin_market/service/entity/voucher_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  late ScrollController _scrollController;
  bool _isHidenFloatingButton = false;

  final _streamController = StreamController<(DocumentChangeType, Voucher)>();

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

    VoucherService.instance.listenChanges(_streamController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streamController.stream.listen((event) {
        switch (event.$1) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            context.read<VoucherCubit>().addOrUpdateIfExist(event.$2);
            break;
          case DocumentChangeType.removed:
            context.read<VoucherCubit>().remove(event.$2);
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
        title: const Text("Admin - Vouchers management"),
      ),
      body: BlocBuilder<VoucherCubit, Map<String, Voucher>>(
        builder: (_, state) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: defPading / 2),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.values.length,
            itemBuilder: (_, index) {
              return VoucherCard(voucher: state.values.elementAt(index));
            },
          ),
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
                      builder: (context) => const VoucherEditor(),
                    ));
              },
              child: const Icon(Icons.add_outlined),
            ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    _scrollController.dispose();
    super.dispose();
  }
}
