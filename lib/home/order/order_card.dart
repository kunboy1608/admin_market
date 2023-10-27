import 'package:admin_market/bloc/product_cubit.dart';
import 'package:admin_market/entity/order.dart';
import 'package:admin_market/entity/product.dart';
import 'package:admin_market/home/order/order_editor.dart';
import 'package:admin_market/service/entity/order_admin_service.dart';
import 'package:admin_market/service/entity/product_service.dart';
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

  void _nextStatus(BuildContext context) {
    OrderAdminService.instance.forwardStep(order);

    // Incre quantity sold
    if (order.status == 1) {
      order.products?.forEach((key, value) {
        Product? p = context.read<ProductCubit>().currentState()[key];
        if (p != null) {
          p.quantitySold = (p.quantitySold ?? 0) + value.values.first;
          ProductService.instance.update(p);
        }
      });
    }
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
          title: Text(
            "User: ${order.userId}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          subtitle: Text(
              "Total: ${formatCurrency(_sum())}\nCreated date: ${order.uploadDate?.toDate().toString()}"),
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
