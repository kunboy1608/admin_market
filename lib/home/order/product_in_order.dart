import 'dart:io';

import 'package:admin_market/entity/product.dart';
import 'package:admin_market/service/entity/product_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:admin_market/util/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductInOrder extends StatefulWidget {
  const ProductInOrder(
      {super.key,
      required this.productId,
      required this.quantity,
      required this.price});
  final String productId;
  final int quantity;
  final double price;

  @override
  State<ProductInOrder> createState() => _ProductInOrderState();
}

class _ProductInOrderState extends State<ProductInOrder> {
  late Product _product;

  Widget _getPriceWidget() {
    final now = Timestamp.now();
    if (_product.discountPrice != null &&
        (_product.startDiscountDate != null ||
            _product.endDiscountDate != null) &&
        (_product.startDiscountDate == null ||
            now.compareTo(_product.startDiscountDate!) > 0) &&
        (_product.endDiscountDate == null ||
            now.compareTo(_product.endDiscountDate!) < 0)) {
      return RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: formatCurrency(_product.price),
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              text: "\n${formatCurrency(_product.discountPrice)}",
            ),
          ],
        ),
      );
    }
    return Text("${formatCurrency(_product.price)} ",
        maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  @override
  void initState() {
    super.initState();
    _product = Product()
      ..id = widget.productId
      ..price = 600000.0
      ..name = "Loading ...";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ProductService.instance.getById(widget.productId).then((value) {
      if (value != null) {
        setState(() {
          _product = value;
        });
      }
    });
    _product.price = widget.price;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Hero(
                tag: 'thumbnail${_product.id ?? ""}',
                child: SizedBox(
                  height: 160.0,
                  width: 160.0,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(defRadius),
                      child: _product.actuallyLink != null &&
                              _product.actuallyLink!.isNotEmpty
                          ? FadeInImage(
                              placeholder:
                                  const AssetImage('assets/img/loading.gif'),
                              image: FileImage(File(_product.actuallyLink!)),
                            )
                          : const Icon(
                              Icons.add_rounded,
                              size: 160.0,
                            )),
                )),
            const SizedBox(width: defPading),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product.name ?? "",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: defPading),
                _getPriceWidget(),
                const SizedBox(height: defPading),
                Card(child: Text("Quantity: ${widget.quantity.toString()}")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
