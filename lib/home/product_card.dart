import 'package:admin_market/bloc/product_cubit.dart';
import 'package:admin_market/entity/product.dart';
import 'package:admin_market/home/product_editor.dart';
import 'package:admin_market/util/const.dart';
import 'package:admin_market/util/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.pro,
    required this.setTimer,
    required this.oldProducts,
    required this.undo,
  });

  final Product pro;

  final Function() setTimer;
  final Function(String) undo;
  final List<Product> oldProducts;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin {
  late Product _pro;
  @override
  void initState() {
    super.initState();
    _pro = widget.pro;
  }

  void _deleteById(String id) {
    final currentList = context.read<ProductCubit>().currentState().values;
    String nameProduct = "";

    for (int i = 0; i < currentList.length; i++) {
      if (id == currentList.elementAt(i).id) {
        nameProduct = currentList.elementAt(i).name ?? nameProduct;

        widget.oldProducts.add(currentList.elementAt(i));
        context.read<ProductCubit>().remove(currentList.elementAt(i));

        widget.setTimer.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deleted product: $nameProduct"),
            action: SnackBarAction(
              label: "UNDO",
              onPressed: () => widget.undo(id),
            ),
          ),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ProductEditor(
                    data: widget.pro,
                  ))),
      child: Dismissible(
        key: _pro.id == null ? UniqueKey() : Key(_pro.id!.toString()),
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          color: Theme.of(context).colorScheme.errorContainer,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 80.0, 0.0),
            child: Icon(Icons.delete),
          ),
        ),
        onDismissed: (_) => _deleteById(_pro.id!),
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
                            ? FadeInImage.assetNetwork(
                                placeholder: 'assets/img/loading.gif',
                                image: widget.pro.actuallyLink!,
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
                    _pro.provider ?? "",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    formatCurrency(_pro.price),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
