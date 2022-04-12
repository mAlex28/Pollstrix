import 'package:flutter/material.dart';
import 'package:pollstrix/utilities/custom/dialogs/custom_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Logout',
      content: 'Are you sure you want to logout?',
      optionsBuilder: () => {
            'Cancel': false,
            'Logout': true,
          }).then((value) => value ?? false);
}
