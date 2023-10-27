import 'dart:async';

import 'package:admin_market/bloc/order_cubit.dart';
import 'package:admin_market/entity/order.dart';
import 'package:admin_market/home/order/list_orders_widget.dart';
import 'package:admin_market/service/entity/order_admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => OrderpageState();
}

class OrderpageState extends State<OrderPage> {
  late List<Tab> _tabs;
  late List<Widget> _tabViews;

  final _streamController = StreamController<(DocumentChangeType, Order)>();

  @override
  void initState() {
    super.initState();
    _tabs = const [
      Tab(text: "Cart"),
      Tab(text: "Waitting to confirm"),
      Tab(text: "Waiting to delivery man take product"),
      Tab(text: "Delivering"),
      Tab(text: "Delivered"),
      Tab(text: "Cancelled"),
      Tab(text: "Refund"),
    ];

    _tabViews = const [
      ListOrdersWidget(status: 0),
      ListOrdersWidget(status: 1),
      ListOrdersWidget(status: 2),
      ListOrdersWidget(status: 3),
      ListOrdersWidget(status: 4),
      ListOrdersWidget(status: 5),
      ListOrdersWidget(status: 6),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderAdminService.instance.listenChanges(_streamController);
      _streamController.stream.listen((event) {
        switch (event.$1) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            context.read<OrderCubit>().addOrUpdateIfExist(event.$2);
            break;
          case DocumentChangeType.removed:
            context.read<OrderCubit>().remove(event.$2);
            break;
          default:
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("OrderPage: didChangeDependencies");
  }

  @override
  void didUpdateWidget(covariant OrderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint("OrderPage: didUpdateWidget");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
          appBar: AppBar(
              title: const Text("Admin - Order management"),
              bottom: TabBar(isScrollable: true, tabs: _tabs)),
          body: TabBarView(
            children: _tabViews,
          )),
    );
  }
}
