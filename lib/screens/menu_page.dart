import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/screens/faq_page.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/custom/change_theme_button.dart';
import 'package:pollstrix/custom/custom_menu_list_item.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(360, 690),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);

    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        SizedBox(
          height: kToolbarHeight * 0.7,
          child: Image.asset(
            "assets/images/logo_inapp.png",
            color: kAccentColor,
          ),
        ),
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: const [
              ChangeThemeButtonWidget(),
            ]),
        body: Center(
            child: Column(
          children: <Widget>[
            header,
            SizedBox(height: kSpacingUnit.w * 4),
            Expanded(
                child: ListView(
              children: <Widget>[
                const CustomMenuListItem(
                  icon: Icons.translate_outlined,
                  text: 'Language',
                ),
                const CustomMenuListItem(icon: Icons.share, text: 'Invite'),
                CustomMenuListItem(
                  icon: Icons.question_answer_outlined,
                  text: 'FAQ',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const FAQPage())),
                ),
                CustomMenuListItem(
                  icon: Icons.info_outline_rounded,
                  text: 'About',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Pollstrix',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'This application is for education purpose only',
                    applicationIcon: SizedBox(
                      height: kToolbarHeight * 0.6,
                      child: Image.asset(
                        "assets/images/icon.png",
                        color: kAccentColor,
                      ),
                    ),
                  ),
                ),
                const CustomMenuListItem(
                    icon: Icons.star_rate_outlined, text: 'Rate us'),
                CustomMenuListItem(
                  icon: Icons.logout_outlined,
                  text: 'Log out',
                  onTap: () {
                    Provider.of<AuthenticationService>(context, listen: false)
                        .signOut(context: context);
                  },
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Developed by Alex',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ],
            ))
          ],
        )));
  }
}
