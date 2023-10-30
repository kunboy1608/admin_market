import 'package:admin_market/bloc/product_cubit.dart';
import 'package:admin_market/bloc/voucher_cubit.dart';
import 'package:admin_market/entity/order.dart';
import 'package:admin_market/entity/product.dart';
import 'package:admin_market/entity/voucher.dart';
import 'package:admin_market/home/order/product_in_order.dart';
import 'package:admin_market/service/entity/order_admin_service.dart';
import 'package:admin_market/service/entity/product_service.dart';
import 'package:admin_market/util/string_utils.dart';
import 'package:admin_market/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderEditor extends StatefulWidget {
  const OrderEditor({super.key, required this.order});
  final Order order;

  @override
  State<OrderEditor> createState() => _OrderEditorState();
}

class _OrderEditorState extends State<OrderEditor> {
  Widget _summaryWidget(BuildContext context) {
    double sum = 0.0;
    double discount = 0.0;

    widget.order.products?.forEach(
      (key, value) {
        sum += double.parse(value.keys.first);
      },
    );

    Voucher? voucher;

    if (widget.order.vouchers != null && widget.order.vouchers!.isNotEmpty) {
      voucher = widget.order.vouchers!.isNotEmpty
          ? context.read<VoucherCubit>().state[widget.order.vouchers!.first]
          : null;
      if (voucher != null) {
        if (voucher.percent != null && voucher.percent! > 0) {
          discount = sum * (voucher.percent! / 100);
          if (voucher.maxValue != null && voucher.maxValue! > 0) {
            discount = discount.clamp(0, voucher.maxValue!);
          }
        } else {
          discount = (voucher.maxValue ?? 0).clamp(0, sum);
        }
      }
    }

    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            subtitle: Text(
                "Address: ${widget.order.address}\nPhone number: ${widget.order.phoneNumber}"),
          ),
          ListTile(
            isThreeLine: true,
            subtitle: Text(
                "Subtotal: ${formatCurrency(sum)}\nDiscount: ${formatCurrency(discount)} \nAmount: ${formatCurrency(sum - discount)}"),
            trailing: voucher != null
                ? Text(
                    "${voucher.id}\n${voucher.percent}%\nMax:${formatCurrency(voucher.maxValue)}")
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order details"),
        actions: widget.order.status != 0
            ? [
                IconButton(
                    onPressed: () {
                      WidgetUtil.showYesNoDialog(
                              context, "Are you sure CONFIRM this order?",
                              yesText: "Confirm")
                          .then((value) {
                        if (value != null && value == true) {
                          OrderAdminService.instance
                              .forwardStep(widget.order)
                              .then((_) {
                            // Incre quantity sold
                            if (widget.order.status == 1) {
                              widget.order.products?.forEach((key, value) {
                                Product? p = context
                                    .read<ProductCubit>()
                                    .currentState()[key];
                                if (p != null) {
                                  p.quantitySold = (p.quantitySold ?? 0) +
                                      value.values.first;
                                  ProductService.instance.update(p);
                                }
                              });
                            }

                            Navigator.pop(context);
                          });
                        }
                      });
                    },
                    icon: const Icon(Icons.forward_rounded)),
                IconButton(
                    onPressed: () {
                      WidgetUtil.showYesNoDialog(
                              context, "Are you sure REFUND this order?",
                              yesText: "Refund")
                          .then((value) {
                        if (value != null && value == true) {
                          OrderAdminService.instance
                              .refund(widget.order)
                              .then((_) => Navigator.pop(context));
                        }
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded)),
                IconButton(
                    onPressed: () {
                      WidgetUtil.showYesNoDialog(
                              context, "Are you sure CANCEL this order?",
                              yesText: "Sure")
                          .then((value) {
                        if (value != null && value == true) {
                          OrderAdminService.instance
                              .cancel(widget.order)
                              .then((_) => Navigator.pop(context));
                        }
                      });
                    },
                    icon: const Icon(Icons.clear_rounded)),
              ]
            : null,
      ),
      body: ListView.builder(
        itemCount: widget.order.products?.length ?? 0,
        itemBuilder: (context, index) {
          return ProductInOrder(
            productId: widget.order.products!.keys.elementAt(index),
            quantity: widget.order.products!.values.first.values.first,
            price: double.parse(widget.order.products!.values.first.keys.first),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<VoucherCubit, Map<String, Voucher>>(
          builder: (context, state) => _summaryWidget(context)),
    );
  }
}
