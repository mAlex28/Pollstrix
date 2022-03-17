import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_searchbar_delegate.dart';
import 'package:pollstrix/custom/poll_tile.dart';

class FeedContentPage extends StatefulWidget {
  const FeedContentPage({Key? key}) : super(key: key);

  @override
  _FeedContentPageState createState() => _FeedContentPageState();
}

class _FeedContentPageState extends State<FeedContentPage> {
  final db = FirebaseFirestore.instance;
  List<String> searchItems = [
    "Apple",
    "Banana",
    "Pineapple",
    "Pear",
    "Watermelon",
    "Organe",
    "Blueberries"
  ];
  String searchKey = 'test';
  search() {
    return db
        .collection('Col-Name')
        .where('fieldName', isGreaterThanOrEqualTo: searchKey)
        .where('fieldName', isLessThan: searchKey + 'z')
        .snapshots()
        .toList();
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
            IconButton(
              icon: const Icon(
                Icons.sort_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                // do something
              },
            )
          ],
        ),
        body: Column(children: [
          Flexible(
              child: StreamBuilder<QuerySnapshot>(
            stream: db
                .collection('polls')
                .orderBy('createdAt', descending: true)
                .snapshots(),
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
