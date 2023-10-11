import 'dart:io';

import 'package:admin_market/entity/product.dart';
import 'package:admin_market/home/product_editor.dart';
import 'package:admin_market/util/const.dart';
import 'package:admin_market/util/string_utils.dart';
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
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "Provider: ${_pro.provider ?? ""}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "Price: ${formatCurrency(_pro.price)}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "Category: ${_pro.categoryId?.toString() ?? ""}",
                      style: Theme.of(context).textTheme.titleMedium,
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
