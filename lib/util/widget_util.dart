import 'package:admin_market/util/const.dart';
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

  static Future<bool?> showYesNoDialog(BuildContext context, String message,
      {String yesText = "Yes", String noText = "No"}) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(defPading),
            child: Column(
              children: [
                Text(message),
                const SizedBox(height: defPading / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.onErrorContainer),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text(yesText)),
                    const SizedBox(width: defPading),
                    FilledButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(noText)),
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
