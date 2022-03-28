import 'package:flutter/material.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:provider/provider.dart';

class ChangeThemeButtonWidget extends StatefulWidget {
  const ChangeThemeButtonWidget({Key? key}) : super(key: key);

  @override
  _ChangeThemeButtonWidgetState createState() =>
      _ChangeThemeButtonWidgetState();
}

class _ChangeThemeButtonWidgetState extends State<ChangeThemeButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = Provider.of<ThemeProvider>(context).currentTheme;

    return IconButton(
      icon: currentTheme == 'dark'
          ? Icon(
              Icons.dark_mode_outlined,
              color: Theme.of(context).iconTheme.color,
            )
          : Icon(
              Icons.light_mode_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
      onPressed: () {
        setState(() {
          if (currentTheme == 'dark') {
            themeProvider.changeTheme('light');
          } else {
            themeProvider.changeTheme('dark');
          }
        });
      },
    );
  }
}
