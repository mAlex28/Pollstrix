import 'package:flutter/material.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:provider/provider.dart';

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // return IconButton(
    //     onPressed: () {
    //       final provider = Provider.of<ThemeProvider>(context, listen: false);
    //       provider.toggleTheme();
    //     },
    //     icon: const Icon(Icons.brightness_6_rounded));

    return Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) async {
          final provider = Provider.of<ThemeProvider>(context, listen: false);
          provider.toggleTheme(value);
        });
  }
}
