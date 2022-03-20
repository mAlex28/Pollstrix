import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants.dart';
import 'package:pollstrix/custom/custom_menu_list_item.dart';
import 'package:pollstrix/screens/user_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final urlImage = "assets/images/avatar.png";

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
        themeSwitcher,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return ThemeSwitchingArea(child: Builder(builder: (context) {
      return Scaffold(
          body: Column(
        children: <Widget>[
          SizedBox(height: kSpacingUnit.w * 5),
          header,
          Expanded(
              child: ListView(
            children: <Widget>[
              CustomMenuListItem(icon: Icons.shield, text: 'Privacy')
            ],
          ))
        ],
      ));
    }));

    //   return ListView(
    //     children: [
    //       FutureBuilder(
    //           future:
    //               Provider.of<AuthenticationService>(context).getCurrentUser(),
    //           builder: (context, snapshot) {
    //             if (snapshot.connectionState == ConnectionState.done) {
    //               return buildHeader(context, snapshot);
    //             } else {
    //               return const CircularProgressIndicator();
    //             }
    //           }),
    //       Container(
    //         padding: const EdgeInsets.symmetric(horizontal: 20),
    //         child: Column(
    //           children: [
    //             const SizedBox(height: 20),
    //             CustomMenuListItem(icon: Icons.shield, text: 'Privacy'),
    //             buildMenuItem(
    //               text: 'Language',
    //               icon: Icons.language_rounded,
    //               onClicked: () => {},
    //             ),
    //             buildMenuItem(
    //               text: 'Settings',
    //               icon: Icons.settings_rounded,
    //               onClicked: () => {},
    //             ),
    //             buildMenuItem(
    //               text: 'About us',
    //               icon: Icons.info_rounded,
    //               onClicked: () => {},
    //             ),
    //             buildMenuItem(
    //               text: 'Invite',
    //               icon: Icons.share_rounded,
    //               onClicked: () => {},
    //             ),
    //             buildMenuItem(
    //                 text: 'Sign out',
    //                 icon: Icons.logout_rounded,
    //                 onClicked: () {
    //                   Provider.of<AuthenticationService>(context, listen: false)
    //                       .signOut(context: context);
    //                 }),
    //             const SizedBox(height: 20),
    //             const Text(
    //               'Developed by Alex',
    //               style: TextStyle(fontSize: 12),
    //             )
    //           ],
    //         ),
    //       )
    //     ],
    //   );
    // }

    // Widget buildHeader(context, snapshot) {
    //   final userData = snapshot.data;

    //   return InkWell(
    //       onTap: () => Navigator.of(context).push(MaterialPageRoute(
    //             builder: (context) => const UserPage(),
    //           )),
    //       child: Container(
    //         color: Colors.lightBlue.shade600,
    //         padding: const EdgeInsets.symmetric(horizontal: 20).add(
    //           (const EdgeInsets.symmetric(vertical: 20)),
    //         ),
    //         child: Row(
    //           children: [
    //             CircleAvatar(
    //                 radius: 30,
    //                 backgroundImage: Provider.of<AuthenticationService>(context)
    //                     .getProfileImage()),
    //             const SizedBox(width: 20),
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   "${userData.displayName ?? "Unkown"}",
    //                   style: const TextStyle(fontSize: 20, color: Colors.white),
    //                 ),
    //                 const SizedBox(height: 4),
    //                 Text(
    //                   "${userData.email ?? "Anonymous"}",
    //                   style: const TextStyle(fontSize: 14, color: Colors.white),
    //                 ),
    //               ],
    //             ),
    //             const Spacer(),
    //           ],
    //         ),
    //       ));
    // }

    // Widget buildMenuItem(
    //     {required String text, required IconData icon, VoidCallback? onClicked}) {
    //   final color = Colors.black;
    //   final hoverColor = Colors.black;

    //   return ListTile(
    //     leading: Icon(
    //       icon,
    //       color: color,
    //     ),
    //     title: Text(
    //       text,
    //       style: TextStyle(color: color),
    //     ),
    //     hoverColor: hoverColor,
    //     onTap: onClicked,
    //   );
    // }

    // void selectedItem(BuildContext context, int index) {
    //   Navigator.of(context).pop();

    //   switch (index) {
    //     case 0:
    //       // Navigator.of(context).push(MaterialPageRoute(
    //       //   builder: (context) {},
    //       // ));
    //       break;
    //     case 1:
    //       // Navigator.of(context).push(MaterialPageRoute(
    //       //   builder: (context) => const TestPage(),
    //       // ));
    //       break;
    //   }
    // }
  }
}
