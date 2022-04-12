import 'package:flutter/material.dart';
import 'package:pollstrix/utilities/custom/dialogs/custom_dialog.dart';

Future<void> showPasswordValidateDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
      context: context,
      title: 'Validate password',
      content: text,
      optionsBuilder: () => {
            'OK': null,
          });
}
