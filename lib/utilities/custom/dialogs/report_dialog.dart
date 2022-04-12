import 'package:flutter/material.dart';
import 'package:pollstrix/utilities/custom/dialogs/custom_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Report',
      content: 'Are you sure you want to report this poll?',
      optionsBuilder: () => {
            'No': false,
            'Yes': true,
          }).then((value) => value ?? false);
}
