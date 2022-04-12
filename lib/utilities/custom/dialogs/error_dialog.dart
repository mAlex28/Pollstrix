import 'package:flutter/material.dart';
import 'package:pollstrix/utilities/custom/dialogs/custom_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
      context: context,
      title: 'Error',
      content: text,
      optionsBuilder: () => {
            'OK': null,
          });
}
