import 'package:flutter/material.dart';

class CustomWidgets {
  static SnackBar customSnackbar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.blueGrey,
      content: Text(
        content,
        style: const TextStyle(color: Colors.white, letterSpacing: 0.5),
      ),
    );
  }
}
