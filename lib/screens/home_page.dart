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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const PostPollPage()))));
  }
}
