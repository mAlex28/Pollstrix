import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pollstrix/custom/poll_tile.dart';

class CustomSearchBarDelegate extends SearchDelegate {
  final _firebaseFirestore = FirebaseFirestore.instance;

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
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
              showSuggestions(context);
            }
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
              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting) {
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
    var stream = _firebaseFirestore
        .collection('polls')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .snapshots();

    return Container(
        color: Colors.white,
        child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (query.isEmpty) return buildNoSuggestions();

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return buildNoSuggestions();
            } else {
              return buildSuggestionsSuccess(snapshot.data!.docs);
            }
          },
        ));
  }

  Widget buildNoSuggestions() => const Center(
        child: Text(
          'No suggestions',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      );

  Widget buildSuggestionsSuccess(
          List<QueryDocumentSnapshot<Object?>> suggestions) =>
      ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          final queryText = (suggestion.data() as dynamic)['title']
              .substring(0, query.length);
          final remainingText =
              (suggestion.data() as dynamic)['title'].substring(query.length);

          return ListTile(
              onTap: () {
                query = (suggestion.data() as dynamic)['title'];
                showResults(context);
              },
              title: RichText(
                text: TextSpan(
                    text: queryText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: remainingText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ]),
              ));
        },
      );
}
