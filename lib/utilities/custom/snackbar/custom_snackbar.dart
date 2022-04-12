import 'package:flutter/material.dart';

class CustomSnackbar {
  static SnackBar customSnackbar(
      {required String content, required Color backgroundColor}) {
    return SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        content,
        style: const TextStyle(color: Colors.white, letterSpacing: 0.5),
      ),
    );
  }
}
