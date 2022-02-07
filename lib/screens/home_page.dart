import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/screens/login_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

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
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(child: _pages.elementAt(_selectedIndex)

          //  Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text(
          //       '( ${_user.email!} )',
          //       style: const TextStyle(
          //         fontSize: 20,
          //         letterSpacing: 0.5,
          //       ),
          //     ),
          //     const SizedBox(height: 24.0),
          //     _isSigningOut
          //         ? const CircularProgressIndicator()
          //         : ElevatedButton(
          //             onPressed: () async {
          //               setState(() {
          //                 _isSigningOut = true;
          //               });
          //               await context
          //                   .read<AuthenticationService>()
          //                   .signOut(context: context);
          //               setState(() {
          //                 _isSigningOut = false;
          //               });
          //               Navigator.of(context)
          //                   .pushReplacement(_routeToSignInScreen());
          //             },
          //             child: const Text("Sign out"),
          //           ),
          //   ],
          // ),
          ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          mouseCursor: SystemMouseCursors.grab,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.post_add_rounded), label: 'Post'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_rounded), label: 'Menu')
          ]),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _pages = <Widget>[
    Icon(Icons.call, size: 150),
    Icon(Icons.post_add_rounded, size: 150),
    Icon(Icons.menu_rounded, size: 150),
  ];
}
