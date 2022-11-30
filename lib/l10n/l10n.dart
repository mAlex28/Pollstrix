import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('si'),
    const Locale('ta'),
  ];

  static String getLanguage(String code, context) {
    switch (code) {
      case 'si':
        return AppLocalizations.of(context)!.language;
      case 'ta':
        return AppLocalizations.of(context)!.language;
      case 'en':
      default:
        return AppLocalizations.of(context)!.language;
    }
  }
}
