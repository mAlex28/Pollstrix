import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/polls/cloud_poll.dart';
import 'package:pollstrix/services/cloud/polls/firebase_poll_functions.dart';
import 'package:pollstrix/utilities/custom/poll/poll_tile.dart';

class CustomSearchBarDelegate extends SearchDelegate {
  final FirebasePollFunctions _pollService = FirebasePollFunctions();

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

    var stream = _pollService.searchForPolls(query: query);

    return Column(
      children: <Widget>[
        Flexible(
          child: StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allPolls = snapshot.data as Iterable<CloudPoll>;
                    return ListView.builder(
                      itemCount: allPolls.length,
                      itemBuilder: (context, index) {
                        final poll = allPolls.elementAt(index);
                        return PollTile(doc: poll);
                      },
                    );
                  } else if (!snapshot.hasData) {
                    return Column(
                      children: const <Widget>[
                        Text(
                          "No Results Found.",
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Center(child: CircularProgressIndicator()),
                      ],
                    );
                  }
                default:
                  return const Center(
                    child: CircularProgressIndicator(),
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
    var stream = _pollService.searchForPolls(query: query);

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (query.isEmpty) return buildNoSuggestions();

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (snapshot.hasData) {
              final allResults = snapshot.data as Iterable<CloudPoll>;
              return buildSuggestionsSuccess(allResults);
            } else if (!snapshot.hasData) {
              return buildNoSuggestions();
            } else {
              return buildNoSuggestions();
            }
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }

        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: CircularProgressIndicator());
        // } else if (snapshot.hasError || !snapshot.hasData) {
        //   return buildNoSuggestions();
        // } else {
        //   return buildSuggestionsSuccess(snapshot.data!.docs);
        // }
      },
    );
  }

  Widget buildNoSuggestions() => const Center(
        child: Text(
          'No suggestions',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      );

  Widget buildSuggestionsSuccess(Iterable<CloudPoll> suggestions) =>
      ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions.elementAt(index);
          final queryText = suggestion.title;
          final remainingText = suggestion.title.substring(query.length);

          return ListTile(
              onTap: () {
                query = suggestion.title as dynamic;
                // query = (suggestion.data() as dynamic)[titleField];
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
