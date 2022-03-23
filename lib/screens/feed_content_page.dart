import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants.dart';
import 'package:pollstrix/custom/custom_searchbar_delegate.dart';
import 'package:pollstrix/custom/poll_tile.dart';
import 'package:pollstrix/services/auth_service.dart';

class FeedContentPage extends StatefulWidget {
  const FeedContentPage({Key? key}) : super(key: key);

  @override
  _FeedContentPageState createState() => _FeedContentPageState();
}

class _FeedContentPageState extends State<FeedContentPage> {
  final db = FirebaseFirestore.instance;
  var stream;

  @override
  void initState() {
    super.initState();
    stream = db
        .collection('polls')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pollstrix'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                showSearch(
                    context: context, delegate: CustomSearchBarDelegate());
              },
            ),
            PopupMenuButton(
                icon: const Icon(Icons.sort_rounded),
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
        ]));
  }
}
