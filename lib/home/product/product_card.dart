import 'dart:io';

import 'package:admin_market/entity/product.dart';
import 'package:admin_market/home/product/product_editor.dart';
import 'package:admin_market/util/const.dart';
import 'package:admin_market/util/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.pro,
    required this.onDelete,
  });

  final Product pro;
  final Function(Product) onDelete;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late Product _pro;
  @override
  void initState() {
    super.initState();
    _pro = widget.pro;
  }

  Widget _getPriceWidget() {
    final now = Timestamp.now();
    if (_pro.discountPrice != null &&
        (_pro.startDiscountDate != null || _pro.endDiscountDate != null) &&
        (_pro.startDiscountDate == null ||
            now.compareTo(_pro.startDiscountDate!) > 0) &&
        (_pro.endDiscountDate == null ||
            now.compareTo(_pro.endDiscountDate!) < 0)) {
      return RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: formatCurrency(_pro.price),
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              text: "\n${formatCurrency(_pro.discountPrice)}",
            ),
          ],
        ),
      );
    }
    return Text(
      "${formatCurrency(_pro.price)} ",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pro = widget.pro;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ProductEditor(
                    data: widget.pro,
                  ))),
      child: Padding(
        padding: const EdgeInsets.only(top: defPading),
        child: Dismissible(
          key: UniqueKey(),
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 80.0, 0.0),
              child: Icon(Icons.delete),
            ),
          ),
          confirmDismiss: (direction) async {
            widget.onDelete(widget.pro);
            return true;
          },
          direction: DismissDirection.endToStart,
          child: Card(
            child: Row(
              children: [
                Hero(
                    tag: 'thumbnail${_pro.id}',
                    child: SizedBox(
                      height: 160.0,
                      width: 160.0,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(defRadius),
                          child: widget.pro.actuallyLink != null &&
                                  widget.pro.actuallyLink!.isNotEmpty
                              ? FadeInImage(
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(
                                      'assets/img/loading.gif'),
                                  image:
                                      FileImage(File(widget.pro.actuallyLink!)),
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
                      _pro.name ?? "",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "Provider: ${_pro.provider ?? ""}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    _getPriceWidget(),
                    Text(
                      "Category: ${_pro.categoryId?.toString() ?? ""}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      "Sold: ${_pro.quantitySold?.toString() ?? "0"}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
