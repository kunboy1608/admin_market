import 'package:admin_market/bloc/product_cubit.dart';
import 'package:admin_market/entity/order.dart';
import 'package:admin_market/entity/product.dart';
import 'package:admin_market/home/order/order_editor.dart';
import 'package:admin_market/service/entity/order_admin_service.dart';
import 'package:admin_market/service/entity/product_service.dart';
import 'package:admin_market/service/entity/user_service.dart';
import 'package:admin_market/util/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final Order order;

  double _sum() {
    double sum = 0.0;

    order.products?.forEach((key, value) {
      sum += double.parse(value.keys.first) * value.values.first;
    });

    return sum;
  }

  Future<void> _nextStatus(BuildContext context) async {
    // Incre quantity sold
    debugPrint("${order.status}");
    if (order.status == 1) {
      order.products?.forEach((key, value) async {
        Product? p = context.read<ProductCubit>().currentState()[key];
        p ??= await ProductService.instance.getById(key);
        debugPrint("${p == null}");
        if (p != null) {
          p.quantitySold = (p.quantitySold ?? 0) + value.values.first;
          ProductService.instance.update(p);
        }
        debugPrint("${p == null}");
      });
    }
    OrderAdminService.instance.forwardStep(order);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OrderEditor(
                order: order,
              ),
            ));
      },
      child: Card(
        child: ListTile(
          title: FutureBuilder(
              future: UserService.instance.getById(order.userId ?? ""),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("User: ${order.userId}");
                }
                return Text(
                  "User: ${snapshot.data!.fullName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
          isThreeLine: true,
          subtitle: Text(
              "Subtotal: ${formatCurrency(_sum())}\nCreated date: ${order.uploadDate?.toDate().toString()}"),
          trailing: ![0, 4, 5, 6].contains(order.status)
              ? IconButton(
                  onPressed: () => _nextStatus(context),
                  icon: const Icon(Icons.forward_rounded))
              : null,
        ),
      ),
    );
  }
}
