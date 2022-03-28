import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/screens/faq_page.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/custom/change_theme_button.dart';
import 'package:pollstrix/custom/custom_menu_list_item.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 7,
    remindDays: 2,
    remindLaunches: 5,
    appStoreIdentifier: 'site.alexthedev.pollstrix',
    googlePlayIdentifier: 'site.alexthedev.pollstrix',
  );

  _launchRateDialogOnClick() {
    _rateMyApp.showStarRateDialog(context,
        title: 'Enjoying Pollstrix?',
        message: 'Please leave a rating',
        ignoreNativeDialog: false,
        actionsBuilder: (context, stars) {
          return [
            TextButton(
                onPressed: () async {
                  if (stars != null) {
                    await _rateMyApp
                        .callEvent(RateMyAppEventType.rateButtonPressed);
                    Navigator.pop<RateMyAppDialogButton>(
                        context, RateMyAppDialogButton.rate);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text('OK'))
          ];
        },
        starRatingOptions: const StarRatingOptions(initialRating: 3),
        onDismissed: () => _rateMyApp.callEvent(RateMyAppEventType
            .laterButtonPressed), // Called when the user dismisse
        dialogStyle: const DialogStyle(
          titleAlign: TextAlign.center,
          messageAlign: TextAlign.center,
          messagePadding: EdgeInsets.only(bottom: 20),
        ));
  }

  _launchDialog() {
    _rateMyApp.init().then((_) {
      if (_rateMyApp.shouldOpenDialog) {
        _rateMyApp.showStarRateDialog(context,
            title: 'Enjoying Pollstrix?',
            message: 'Please leave a rating',
            ignoreNativeDialog: false,
            actionsBuilder: (context, stars) {
              return [
                TextButton(
                    onPressed: () async {
                      if (stars != null) {
                        await _rateMyApp
                            .callEvent(RateMyAppEventType.rateButtonPressed);
                        Navigator.pop<RateMyAppDialogButton>(
                            context, RateMyAppDialogButton.rate);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('OK'))
              ];
            },
            starRatingOptions: const StarRatingOptions(initialRating: 3),
            onDismissed: () => _rateMyApp.callEvent(RateMyAppEventType
                .laterButtonPressed), // Called when the user dismisse
            dialogStyle: const DialogStyle(
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 20),
            ));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _launchDialog();
  }

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
                      ),
                    ),
                  ),
                ),
                CustomMenuListItem(
                  icon: Icons.star_rate_outlined,
                  text: 'Rate us',
                  onTap: () => _launchRateDialogOnClick(),
                ),
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
