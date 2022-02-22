import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/screens/post_poll_page.dart';
import 'package:pollstrix/screens/login_page.dart';
import 'package:pollstrix/screens/test_poll.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User _user;
  bool _isSigningOut = false;

  int _selectedIndex = 0;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(-1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const PostPollPage()))));
  }
}
