import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/utilities/custom/buttons/custom_theme_button.dart';
import 'package:pollstrix/utilities/custom/custom_menu_list_item.dart';
import 'package:pollstrix/l10n/l10n.dart';
import 'package:pollstrix/screens/menu/faq_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:pollstrix/services/locale_service.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';
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
        onDismissed: () =>
            _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        // Called when the user dismisse
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
            onDismissed: () =>
                _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
            // Called when the user dismisse
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
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: const [
              CustomThemeButtonWidget(),
            ]),
        body: Center(
            child: Column(
          children: <Widget>[
            header,
            SizedBox(height: kSpacingUnit.w * 4),
            Expanded(
                child: ListView(
              children: <Widget>[
                CustomMenuListItem(
                  icon: Icons.translate_outlined,
                  text: AppLocalizations.of(context)!.language,
                  onTap: () => showAdaptiveActionSheet(
                      context: context,
                      cancelAction: CancelAction(title: const Text('Cancel')),
                      actions: L10n.all.map((locale) {
                        final flag = L10n.getLanguage(locale.languageCode);
                        return BottomSheetAction(
                            title: Text(
                              flag,
                            ),
                            onPressed: () {
                              final provider = Provider.of<LocaleProvider>(
                                  context,
                                  listen: false);
                              provider.setLocale(locale);
                            });
                      }).toList()),
                ),
                CustomMenuListItem(
                  icon: Icons.share,
                  text: 'Invite',
                  onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext builder) => const AlertDialog(
                            content:
                                Text('This feature is still under contruction'),
                          )),
                ),
                CustomMenuListItem(
                  icon: Icons.question_answer_outlined,
                  text: AppLocalizations.of(context)!.faq,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const FAQPage())),
                ),
                CustomMenuListItem(
                  icon: Icons.info_outline_rounded,
                  text: AppLocalizations.of(context)!.about,
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Pollstrix',
                    applicationVersion: '1.0.0',
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
                  text: AppLocalizations.of(context)!.rateUs,
                  onTap: () => _launchRateDialogOnClick(),
                ),
                CustomMenuListItem(
                  icon: Icons.logout_outlined,
                  text: AppLocalizations.of(context)!.logOut,
                  onTap: () async {
                    try {
                      await AuthService.firebase().logOut();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackbar.customSnackbar(
                              backgroundColor: Colors.red,
                              content: 'Could not logout! try again later'));
                    }
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
