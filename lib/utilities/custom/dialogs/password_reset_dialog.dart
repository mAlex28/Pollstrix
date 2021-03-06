import 'package:flutter/material.dart';
import 'package:pollstrix/utilities/custom/dialogs/custom_dialog.dart';

Future<void> showChangePasswordDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
      context: context,
      title: 'Change password',
      content: text,
      optionsBuilder: () => {
            'OK': null,
          });
}
