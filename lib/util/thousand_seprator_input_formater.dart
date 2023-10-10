import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  // ignore: constant_identifier_names
  static const SEPARATOR = '.'; // Change this to ',' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of SEPARATOR character
    String newValueText = newValue.text.replaceAll(SEPARATOR, '');

    if (newValue.text.length >= 20) {
      return oldValue;
    }

    // Fix prefix 0
    newValueText = int.parse(newValueText).toString();

    if (oldValue.text.endsWith(SEPARATOR) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    int selectionIndex = newValue.text.length - newValue.selection.extentOffset;
    final chars = newValueText.split('');

    String newString = '';
    for (int i = chars.length - 1; i >= 0; i--) {
      if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
        newString = SEPARATOR + newString;
      }
      newString = chars[i] + newString;
    }

    return TextEditingValue(
      text: newString.toString(),
      selection: TextSelection.collapsed(
        offset: newString.length - selectionIndex,
      ),
    );
  }
}
