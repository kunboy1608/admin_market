import 'package:admin_market/entity/voucher.dart';
import 'package:admin_market/home/voucher/voucher_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoucherCard extends StatelessWidget {
  const VoucherCard({super.key, required this.voucher});
  final Voucher voucher;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (voucher.id != null) {
          Clipboard.setData(ClipboardData(text: voucher.id!)).then((_) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Copied voucher id")),
            );
          });
        }
      },
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => VoucherEditor(
                voucher: voucher,
              ),
            ));
      },
      child: Card(
        color: voucher.isPublic
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.onInverseSurface,
        child: ListTile(
          leading: const Icon(CupertinoIcons.ticket, size: 60),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Id: ${voucher.id}"),
              Text("Name: ${voucher.name}"),
              Text("Max: ${voucher.maxValue}"),
              Text("Percent: ${voucher.percent}"),
              Text("Count: ${voucher.count?.toString() ?? "0"}"),
              Text("Start: ${voucher.startDate?.toDate().toString() ?? "Now"}"),
              Text(
                  "End: ${voucher.endDate?.toDate().toString() ?? "Unlimited"}"),
            ],
          ),
        ),
      ),
    );
  }
}
