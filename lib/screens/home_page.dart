import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants.dart';
import 'package:pollstrix/screens/feed_content_page.dart';
import 'package:pollstrix/screens/menu_page.dart';
import 'package:pollstrix/screens/post_poll_page.dart';
import 'package:pollstrix/screens/profile_content_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
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

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [FeedContentPage(), ProfileContentPage(), MenuPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: kAccentColor,
        unselectedItemColor: kUnselectedItemColor,
        showUnselectedLabels: true,
        onTap: (value) {
          setState(() {
            _pageController.jumpToPage(value);
          });
        },
        currentIndex:
            _pageController.hasClients ? _pageController.page!.floor() : 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: 'Menu')
        ],
      ),
    );
  }
}
