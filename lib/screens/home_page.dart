import 'package:flutter/material.dart';
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
    return Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const FeedContentPage(),
            ProfileContentPage(),
            const MenuPage()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.blueGrey,
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
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_rounded), label: 'Menu')
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const PostPollPage()))));
  }
}
