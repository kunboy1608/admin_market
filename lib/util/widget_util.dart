import 'package:flutter/material.dart';

class WidgetUtil {
  static Future<dynamic> showLoadingDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
            onWillPop: () async => false));
  }
}
