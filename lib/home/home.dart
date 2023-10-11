import 'dart:async';

import 'package:admin_market/bloc/product_cubit.dart';
import 'package:admin_market/entity/product.dart';
import 'package:admin_market/home/product_card.dart';
import 'package:admin_market/home/product_editor.dart';
import 'package:admin_market/service/firestorage_service.dart';
import 'package:admin_market/service/firestore_service.dart';
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
  final _seconds = 5;
  Timer? _timer;
  late Key _keyListView;

  final _streamController = StreamController<(DocumentChangeType, Product)>();

  void _delete(Product p) {
    String nameProduct = "";

    nameProduct = p.name ?? nameProduct;

    _oldProduct.add(p);

    // cancel previous instance if it exists
    _timer?.cancel();

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

      context.read<ProductCubit>().removeAll(_oldProduct);
      _oldProduct.clear();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_oldProduct.length > 1
            ? "Deleting ${_oldProduct.length} products"
            : "Deleting product: $nameProduct"),
        action: SnackBarAction(
            label: _oldProduct.length > 1 ? "UNDO ALL" : "UNDO",
            onPressed: () {
              context.read<ProductCubit>().addOrUpdateIfExistAll(_oldProduct);
              _oldProduct.clear();
              _timer?.cancel();
            }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FirestoreService.instance
        .listenChanges(Product.collectionName, _streamController);
    _keyListView = UniqueKey();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streamController.stream.listen((event) {
        switch (event.$1) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            context.read<ProductCubit>().addOrUpdateIfExist(event.$2);
            break;
          case DocumentChangeType.removed:
            // Support remove useless img on Firestorage
            FirestorageService.instance.delete(event.$2.imgUrl ?? "");
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _keyListView = UniqueKey();
          });
        },
        child: FutureBuilder(
          key: _keyListView,
          future: _loadData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return BlocBuilder<ProductCubit, Map<String, Product>>(
                  builder: (context, state) {
                return ListView.builder(
                  itemBuilder: (_, index) {
                    final p = state.values.elementAt(index);
                    if (!_oldProduct.contains(p)) {
                      return ProductCard(
                        pro: p,
                        onDelete: _delete,
                      );
                    }
                    return Container();
                  },
                  itemCount: state.values.length,
                );
              });
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
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
