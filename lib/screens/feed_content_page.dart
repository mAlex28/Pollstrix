import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants.dart';
import 'package:pollstrix/custom/custom_searchbar_delegate.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';
import 'package:pollstrix/custom/poll_tile.dart';
import 'package:pollstrix/screens/post_poll_page.dart';
import 'package:pollstrix/services/auth_service.dart';

class FeedContentPage extends StatefulWidget {
  const FeedContentPage({Key? key}) : super(key: key);

  @override
  _FeedContentPageState createState() => _FeedContentPageState();
}

class _FeedContentPageState extends State<FeedContentPage> {
  final db = FirebaseFirestore.instance;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isConnected = true;
  var stream;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    stream = db
        .collection('polls')
        .orderBy('createdAt', descending: true)
        .snapshots();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status $e');
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      if (result != ConnectivityResult.none) {
        _isConnected = true;
      } else {
        _isConnected = false;
      }
    });
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

    return ThemeSwitchingArea(child: Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: SizedBox(
            height: kToolbarHeight * 0.6,
            child: Image.asset(
              "assets/images/logo_inapp.png",
              color: kAccentColor,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: kAccentColor,
              ),
              onPressed: () {
                showSearch(
                    context: context, delegate: CustomSearchBarDelegate());
              },
            ),
            PopupMenuButton(
                icon: const Icon(Icons.sort_rounded, color: kAccentColor),
                elevation: 8.0,
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text(
                          'Sorty by Votes (ASC)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        value: 1,
                        onTap: () {
                          setState(() {
                            stream = db
                                .collection('polls')
                                .orderBy('voteCount')
                                .snapshots();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Sorty by Votes (DESC)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        value: 2,
                        onTap: () {
                          setState(() {
                            stream = db
                                .collection('polls')
                                .orderBy('voteCount', descending: true)
                                .snapshots();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Sort by Likes (ASC)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        value: 3,
                        onTap: () {
                          setState(() {
                            stream = db
                                .collection('polls')
                                .orderBy('likes')
                                .snapshots();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Sort by Likes (DESC)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        value: 4,
                        onTap: () {
                          setState(() {
                            stream = db
                                .collection('polls')
                                .orderBy('likes', descending: true)
                                .snapshots();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Sort by Date (ASC)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        value: 5,
                        onTap: () {
                          setState(() {
                            stream = db
                                .collection('polls')
                                .orderBy('createdAt')
                                .snapshots();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Sort by Date (DESC)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        value: 6,
                        onTap: () {
                          setState(() {
                            stream = db
                                .collection('polls')
                                .orderBy('createdAt', descending: true)
                                .snapshots();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Sort by Running',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        value: 7,
                        onTap: () {
                          setState(() {
                            stream = db
                                .collection('polls')
                                .where('finished', isEqualTo: false)
                                .snapshots();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Sort by Ended',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        value: 8,
                        onTap: () {
                          setState(() {
                            stream = db
                                .collection('polls')
                                .where('finished', isEqualTo: true)
                                .snapshots();
                          });
                        },
                      ),
                    ]),
          ],
        ),
        body: Column(children: [
          Flexible(
              child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              // if (!_isConnected) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //       CustomWidgets.customSnackbar(
              //           backgroundColor: Colors.red, content: 'No connection'));
              // }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView(
                  scrollDirection: Axis.vertical,
                  children: snapshot.data!.docs.map((doc) {
                    return PollTile(
                      doc: doc,
                    );
                  }).toList(),
                );
              }
            },
          )),
        ]),
        floatingActionButton: FloatingActionButton(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const PostPollPage())).then((_) => setState(() {}))),
      );
    }));
  }
}
