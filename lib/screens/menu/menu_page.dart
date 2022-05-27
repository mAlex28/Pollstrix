import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/utilities/custom/buttons/custom_theme_button.dart';
import 'package:pollstrix/utilities/custom/custom_menu_list_item.dart';
import 'package:pollstrix/l10n/l10n.dart';
import 'package:pollstrix/screens/menu/faq_page.dart';
import 'package:pollstrix/services/locale_service.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late SharedPreferences _preferences;
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];

  // global keys for showcasesd
  final GlobalKey _changeThemeKey = GlobalKey();
  final GlobalKey _menusKey = GlobalKey();

  final RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 2,
    minLaunches: 7,
    remindDays: 5,
    remindLaunches: 10,
    appStoreIdentifier: 'site.alexthedev.pollstrix',
    googlePlayIdentifier: 'com.alexdev.pollstrix',
  );

  void storeTutorial() async {
    _preferences = await SharedPreferences.getInstance();

    var prefVal = _preferences.getBool("didShowMenuTutorial");

    if (prefVal == false || prefVal == null) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  _launchRateDialogOnClick() {
    _rateMyApp.showStarRateDialog(context,
        title: AppLocalizations.of(context)!.enjoyingPollstrix,
        message: AppLocalizations.of(context)!.leaveRating,
        ignoreNativeDialog: true,
        actionsBuilder: (context, stars) {
          return [
            TextButton(
                onPressed: () async {
                  if (stars != null || stars! > 0) {
                    Navigator.pop<RateMyAppDialogButton>(
                        context, RateMyAppDialogButton.rate);
                    await _rateMyApp
                        .callEvent(RateMyAppEventType.rateButtonPressed);

                    if ((await _rateMyApp.isNativeReviewDialogSupported) ??
                        false) {
                      await _rateMyApp.launchNativeReviewDialog();
                    }
                    await _rateMyApp.save();
                    await _rateMyApp.launchStore();
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
            title: AppLocalizations.of(context)!.enjoyingPollstrix,
            message: AppLocalizations.of(context)!.leaveRating,
            ignoreNativeDialog: true,
            actionsBuilder: (context, stars) {
              return [
                TextButton(
                    onPressed: () async {
                      if (stars != null || stars! > 0) {
                        await _rateMyApp
                            .callEvent(RateMyAppEventType.rateButtonPressed);
                        Navigator.pop<RateMyAppDialogButton>(
                            context, RateMyAppDialogButton.rate);

                        if ((await _rateMyApp.isNativeReviewDialogSupported) ??
                            false) {
                          await _rateMyApp.launchNativeReviewDialog();
                        }
                        await _rateMyApp.save();
                        await _rateMyApp.launchStore();
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
    storeTutorial();
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _launchDialog();
    });
  }

  @override
  void dispose() {
    super.dispose();
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
            actions: [
              CustomThemeButtonWidget(
                key: _changeThemeKey,
              ),
            ]),
        body: Center(
            child: Column(
          children: <Widget>[
            header,
            SizedBox(height: kSpacingUnit.w * 4),
            Expanded(
                child: ListView(
              key: _menusKey,
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
                  text: AppLocalizations.of(context)!.invite,
                  onTap: () {
                    Share.share(
                        'https://play.google.com/store/apps/details?id=com.alexdev.pollstrix',
                        subject: 'Invite friends');
                  },
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
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (route) => false,
                      );
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

  void showTutorial() async {
    initTargets();
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: const Color.fromARGB(255, 71, 159, 230),
      textSkip: 'SKIP',
      paddingFocus: 10,
      opacityShadow: 0.9,
    )..show();

    await _preferences.setBool("didShowMenuTutorial", true);
  }

  void initTargets() {
    targets.clear(); // clear any targets

    targets.add(
      TargetFocus(
        identify: "_changeThemeKey",
        keyTarget: _changeThemeKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    "Change theme",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Light or dark theme is available",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "_menusKey",
        keyTarget: _menusKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    "Menu",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
