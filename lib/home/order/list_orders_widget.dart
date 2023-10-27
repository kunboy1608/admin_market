import 'package:admin_market/bloc/order_cubit.dart';
import 'package:admin_market/entity/order.dart';
import 'package:admin_market/home/order/order_card.dart';
import 'package:admin_market/util/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListOrdersWidget extends StatefulWidget {
  const ListOrdersWidget({super.key, required this.status})
      : assert(status >= 0 && status <= 6);
  final int status;

  @override
  State<ListOrdersWidget> createState() => _ListOrdersWidgetState();
}

class _ListOrdersWidgetState extends State<ListOrdersWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, Map<String, Order>>(
        builder: (context, state) {
      final list = context.read<OrderCubit>().getOrdersByStatus(widget.status);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: defPading / 2),
        child: ListView.separated(
            itemBuilder: (context, index) => OrderCard(order: list[index]),
            separatorBuilder: (context, index) => const SizedBox(
                  height: defPading,
                ),
            itemCount: list.length),
      );
    });
  }
}
