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
        return '🇱🇰 - Sinhala';
      case 'ta':
        return '🇮🇳 - Tamil';
      case 'en':
      default:
        return '🇬🇧 - English';
    }
  }
}
