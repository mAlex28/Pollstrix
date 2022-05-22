import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kSpacingUnit = 10;

const kDarkPrimaryColor = Color(0xFF212121);
const kDarkSecondaryColor = Color(0xFF373737);
const kLightPrimaryColor = Color(0xFFFFFFFF);
const kLightSecondaryColor = Color(0xFFF3F7FB);
const kAccentColor = Color(0xFF3282B8);
const kUnselectedItemColor = Color.fromARGB(255, 154, 167, 173);
const kSmallTextColor = Colors.grey;

final kTitleTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
  fontWeight: FontWeight.w600,
);

final kCaptionTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.1),
  fontWeight: FontWeight.w100,
);

final kButtonTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.3),
  fontWeight: FontWeight.w400,
  color: kLightPrimaryColor,
);

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _preferences;
  ThemeMode currentTheme = ThemeMode.system;

  ThemeProvider(bool? darkThemeOn) {
    currentTheme = darkThemeOn == null
        ? ThemeMode.system
        : darkThemeOn == true
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  ThemeMode get themeMode {
    if (currentTheme == ThemeMode.light) {
      return ThemeMode.light;
    } else if (currentTheme == ThemeMode.dark) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  changeTheme(ThemeMode theme) async {
    _preferences = await SharedPreferences.getInstance();

    if (theme == ThemeMode.dark) {
      currentTheme = theme;
      await _preferences.setBool("darkTheme", true);
    } else if (theme == ThemeMode.light) {
      currentTheme = theme;
      await _preferences.setBool("darkTheme", false);
    } else {
      currentTheme = theme;
      await _preferences.setBool("darkTheme", false);
    }

    notifyListeners();
  }
}

class MyTheme {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: kDarkPrimaryColor,
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
        color: kLightSecondaryColor,
        fontWeight: FontWeight.w600,
      ),
    ),
    brightness: Brightness.dark,
    fontFamily: 'SFProText',
    primaryColor: kDarkPrimaryColor,
    canvasColor: kDarkPrimaryColor,
    backgroundColor: kDarkSecondaryColor,
    iconTheme: ThemeData.dark().iconTheme.copyWith(
          color: kLightSecondaryColor,
        ),
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'SFProText',
          bodyColor: kLightSecondaryColor,
          displayColor: kLightSecondaryColor,
        ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: kAccentColor, brightness: Brightness.dark),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
        color: kDarkSecondaryColor,
        fontWeight: FontWeight.w600,
      ),
    ),
    brightness: Brightness.light,
    fontFamily: 'SFProText',
    primaryColor: kLightPrimaryColor,
    canvasColor: kLightPrimaryColor,
    backgroundColor: kLightSecondaryColor,
    iconTheme: ThemeData.light().iconTheme.copyWith(
          color: kDarkSecondaryColor,
        ),
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'SFProText',
          bodyColor: kDarkSecondaryColor,
          displayColor: kDarkSecondaryColor,
        ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: kAccentColor, brightness: Brightness.light),
  );
}
