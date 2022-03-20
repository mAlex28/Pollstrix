import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants.dart';
import 'package:pollstrix/custom/custom_menu_list_item.dart';

class ProfileContentPage extends StatefulWidget {
  const ProfileContentPage({Key? key}) : super(key: key);

  @override
  _ProfileContentPageState createState() => _ProfileContentPageState();
}

class _ProfileContentPageState extends State<ProfileContentPage> {
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

    var profileInfo = Expanded(
        child: Column(
      children: <Widget>[
        Container(
          height: kSpacingUnit.w * 10,
          width: kSpacingUnit.w * 10,
          margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
          child: Stack(
            children: <Widget>[
              CircleAvatar(
                radius: kSpacingUnit.w * 5,
                backgroundImage: const AssetImage('assets/images/avatar.png'),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: kSpacingUnit.w * 2.5,
                  width: kSpacingUnit.w * 2.5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    heightFactor: kSpacingUnit.w * 1.5,
                    widthFactor: kSpacingUnit.w * 1.5,
                    child: Icon(
                      Icons.edit,
                      color: kDarkPrimaryColor,
                      size: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: kSpacingUnit.w * 2),
        Text(
          'Nicolas Adams',
          style: kTitleTextStyle,
        ),
        SizedBox(height: kSpacingUnit.w * 0.5),
        Text(
          'nicolasadams@gmail.com',
          style: kCaptionTextStyle,
        ),
        SizedBox(height: kSpacingUnit.w * 2),
        Container(
          height: kSpacingUnit * 4,
          width: kSpacingUnit.w * 20,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
              color: Theme.of(context).colorScheme.secondary),
          child: Center(
            child: Text(
              'Upgrade to PRO',
              style: kButtonTextStyle,
            ),
          ),
        )
      ],
    ));

    var themeSwitcher = ThemeSwitcher(
      builder: (context) {
        return AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              ThemeModelInheritedNotifier.of(context).theme.brightness ==
                      Brightness.dark
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
          firstChild: GestureDetector(
            onTap: () =>
                ThemeSwitcher.of(context).changeTheme(theme: kLightTheme),
            child: Icon(
              Icons.earbuds,
              size: ScreenUtil().setSp(kSpacingUnit.w * 3),
            ),
          ),
          secondChild: GestureDetector(
            onTap: () =>
                ThemeSwitcher.of(context).changeTheme(theme: kDarkTheme),
            child: Icon(
              Icons.mood,
              size: ScreenUtil().setSp(kSpacingUnit.w * 3),
            ),
          ),
        );
      },
    );

    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        Icon(
          Icons.settings,
          size: ScreenUtil().setSp(kSpacingUnit.w * 3),
        ),
        profileInfo,
        themeSwitcher,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return ThemeSwitchingArea(child: Builder(builder: (context) {
      return DefaultTabController(
          length: 4,
          child: Scaffold(
              body: Column(
            children: <Widget>[
              SizedBox(height: kSpacingUnit.w * 5),
              header,
              TabBar(tabs: [
                Tab(
                  text: 'All',
                ),
                Tab(
                  text: 'Posted',
                ),
                Tab(
                  text: 'Voted',
                ),
                Tab(
                  text: 'Liked',
                ),
              ])
            ],
          )));
    }));
  }
}
