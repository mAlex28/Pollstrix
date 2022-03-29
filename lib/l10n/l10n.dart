import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('si'),
    const Locale('ta'),
  ];

  static String getLanguage(String code) {
    switch (code) {
      case 'si':
        return '🇱🇰';
      case 'ta':
        return '🇮🇳';
      case 'en':
      default:
        return '🇬🇧';
    }
  }
}
