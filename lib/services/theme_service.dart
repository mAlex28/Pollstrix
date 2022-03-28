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
  String currentTheme = 'light';

  // ThemeMode themeMode = ThemeMode.light;
  // bool get isDarkMode => themeMode == ThemeMode.dark;

  // void toggleTheme(bool isOn) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   if (isOn) {
  //     themeMode = ThemeMode.dark;
  //     preferences.setBool('isDarkTheme', true);
  //   } else {
  //     themeMode = ThemeMode.light;
  //     preferences.setBool('isDarkTheme', false);
  //   }

  //   themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
  //   notifyListeners();
  // }

  ThemeMode get themeMode {
    if (currentTheme == 'light') {
      return ThemeMode.light;
    } else {
      return ThemeMode.dark;
    }
  }

  changeTheme(String theme) {
    currentTheme = theme;
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
 // ThemeMode _selectedTheme = ThemeMode.system;

  // late SharedPreferences prefs;

  // ThemeProvider(bool darkThemeOn) {
  //   _selectedTheme = darkThemeOn ? ThemeMode.dark : ThemeMode.light;
  // }

  // Future<void> toggleTheme() async {
  //   prefs = await SharedPreferences.getInstance();

  //   if (_selectedTheme == ThemeMode.dark) {
  //     _selectedTheme = ThemeMode.light;
  //     await prefs.setBool("darkTheme", false);
  //   } else {
  //     _selectedTheme == ThemeMode.dark;
  //     await prefs.setBool("darkTheme", true);
  //   }

  //   notifyListeners();
  // }

  // ThemeMode? getTheme() => _selectedTheme;