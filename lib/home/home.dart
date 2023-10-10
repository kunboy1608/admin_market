import 'dart:async';

import 'package:admin_market/bloc/product_cubit.dart';
import 'package:admin_market/entity/product.dart';
import 'package:admin_market/home/product_card.dart';
import 'package:admin_market/home/product_editor.dart';
import 'package:admin_market/service/firestorage_service.dart';
import 'package:admin_market/service/firestore_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Product> _oldProduct = [];
  int _seconds = 0;
  Timer? _timer;

  final _streamController = StreamController<(DocumentChangeType, Product)>();

  void _setTimer() {
    // cancel previous instance if it exists
    _timer?.cancel();

    // add more time waiting multi deletion
    _seconds += 5;

    // Set time delete forever
    _timer = Timer(Duration(seconds: _seconds), () {
      debugPrint("clear forever");
      for (var element in _oldProduct) {
        FirestoreService.instance
            .delete(Product.collectionName, element.id ?? "");
        if (element.imgUrl != null) {
          FirestorageService.instance.delete(element.imgUrl!);
        }
      }
      _oldProduct.clear();
      _seconds = 5;
    });
  }

  void _undo(String id) {
    for (int i = 0; i < _oldProduct.length; i++) {
      if (_oldProduct[i].id == id) {
        context.read<ProductCubit>().addOrUpdateIfExist(_oldProduct[i]);
        _oldProduct.removeAt(i);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FirestoreService.instance
        .listenChanges(Product.collectionName, _streamController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streamController.stream.listen((event) {
        switch (event.$1) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            context.read<ProductCubit>().addOrUpdateIfExist(event.$2);
            break;
          case DocumentChangeType.removed:
            context.read<ProductCubit>().remove(event.$2);
            break;
          default:
        }
      });
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<Map<String, Product>?> _loadData() async {
    return FirestoreService.instance.get(Product.collectionName).then((list) {
      Map<String, Product> map = {};
      list?.forEach((element) {
        final p = element as Product;
        map[p.id ?? ""] = p;
      });
      context.read<ProductCubit>().replaceState(map);
      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("admin")),
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BlocBuilder<ProductCubit, Map<String, Product>>(
                builder: (context, state) {
              return ListView.separated(
                itemBuilder: (_, index) => ProductCard(
                  pro: state.values.elementAt(index),
                  setTimer: _setTimer,
                  undo: _undo,
                  oldProducts: _oldProduct,
                ),
                itemCount: state.length,
                separatorBuilder: (_, __) => const SizedBox(height: defPading),
              );
            });
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // bottomNavigationBar: Container(
      //   height: 80,
      //   color: Colors.redAccent,
      // ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'thumbnail',
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProductEditor()));
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
