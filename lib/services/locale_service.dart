import 'package:flutter/material.dart';
import 'package:pollstrix/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String english = 'en';
const String tamil = 'ta';
const String sinhala = 'si';

class LocaleProvider extends ChangeNotifier {
  late SharedPreferences _preferences;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider(String? langugePref) {
    if (langugePref == english || langugePref == null) {
      _locale = const Locale('en');
    } else if (langugePref == tamil) {
      _locale = const Locale('ta');
    } else {
      _locale = const Locale('si');
    }
  }

  void setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;

    _preferences = await SharedPreferences.getInstance();
    await _preferences.setString("language", locale.languageCode);

    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
