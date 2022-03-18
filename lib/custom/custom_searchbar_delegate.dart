import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/poll_tile.dart';

class CustomSearchBarDelegate extends SearchDelegate {
  final _firebaseFirestore = FirebaseFirestore.instance;
  List<String> searchItems = [
    "Apple",
    "Banana",
    "Pineapple",
    "Pear",
    "Watermelon",
    "Organe",
    "Blueberries"
  ];

  // @override
  // ThemeData appBarTheme(BuildContext context) {
  //   final ThemeData theme = Theme.of(context);

  //   return theme;
  // }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear_rounded))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_rounded));
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }

    var stream = _firebaseFirestore
        .collection('polls')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .snapshots();

    return Column(
      children: <Widget>[
        Flexible(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              } else if (snapshot.data!.size == 0) {
                return Column(
                  children: const <Widget>[
                    Text(
                      "No Results Found.",
                    ),
                  ],
                );
              } else {
                return ListView(
                  scrollDirection: Axis.vertical,
                  children: snapshot.data!.docs.map((doc) {
                    return PollTile(doc: doc);
                  }).toList(),
                );
              }
            },
          ),
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
    // List<String> matchQuery = [];

    // for (var fruit in searchItems) {
    //   if (fruit.toLowerCase().contains(query.toLowerCase())) {
    //     matchQuery.add(fruit);
    //   }
    // }
    // return ListView.builder(
    //     itemCount: matchQuery.length,
    //     itemBuilder: (context, index) {
    //       var result = matchQuery[index];
    //       return ListTile(
    //         title: Text(result),
    //       );
    //     });
  }
}
