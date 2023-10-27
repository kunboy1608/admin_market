import 'dart:async';
import 'dart:io';

import 'package:admin_market/bloc/product_cubit.dart';
import 'package:admin_market/entity/product.dart';
import 'package:admin_market/home/product/product_card.dart';
import 'package:admin_market/home/product/product_editor.dart';
import 'package:admin_market/service/entity/product_service.dart';
import 'package:admin_market/service/google/firestorage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _HomeState();
}

class _HomeState extends State<ProductPage> {
  final List<Product> _oldProduct = [];
  final _seconds = 5;
  Timer? _timer;

  bool? _isSortedByCategory;

  final _streamController = StreamController<(DocumentChangeType, Product)>();

  late ScrollController _scrollController;
  bool _isHidenFloatingButton = false;

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
        ProductService.instance.delete(element.id ?? "");
        if (element.imgUrl != null) {
          if (element.actuallyLink != null &&
              element.actuallyLink!.isNotEmpty) {
            final file = File(element.actuallyLink!);
            file.exists().then((value) => value ? file.delete() : ());
          }
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
    ProductService.instance.listenChanges(_streamController);

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
      _streamController.stream.listen((event) {
        _isSortedByCategory = null;
        switch (event.$1) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            context.read<ProductCubit>().addOrUpdateIfExist(event.$2);
            break;
          case DocumentChangeType.removed:
            // Support remove useless img on Firestorage
            context.read<ProductCubit>().remove(event.$2);
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
        title: const Text("Admin - Product management"),
        actions: [
          PopupMenuButton<bool>(
            onSelected: (value) {
              if (value != _isSortedByCategory) {
                _isSortedByCategory = value;
                if (_isSortedByCategory!) {
                  context.read<ProductCubit>().sortByCategory();
                } else {
                  context.read<ProductCubit>().sortByName();
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
              const PopupMenuItem<bool>(
                value: false,
                child: Text('Order by Product\'s name'),
              ),
              const PopupMenuItem<bool>(
                value: true,
                child: Text('Order by Product\'s category'),
              ),
            ],
          )
        ],
      ),
      body: RefreshIndicator(onRefresh: () async {
        setState(() {
          _isSortedByCategory = false;
        });
      }, child: BlocBuilder<ProductCubit, Map<String, Product>>(
          builder: (context, state) {
        return ListView.builder(
          controller: _scrollController,
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
      })),
      floatingActionButton: _isHidenFloatingButton
          ? null
          : FloatingActionButton(
              heroTag: 'thumbnail',
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const ProductEditor()));
              },
              child: const Icon(Icons.add_outlined),
            ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
