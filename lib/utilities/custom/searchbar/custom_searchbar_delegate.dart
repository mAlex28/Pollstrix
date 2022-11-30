import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        children: <Widget>[
          Center(
            child: Text(AppLocalizations.of(context)!.longSearchTerm),
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
                        return PollTile(
                            doc: poll,
                            index: index,
                            pollList: allPolls.toList());
                      },
                    );
                  } else if (!snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.noResultsFound),
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
        if (query.isEmpty) return buildNoSuggestions(context);

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (snapshot.hasData) {
              final allResults = snapshot.data as Iterable<CloudPoll>;
              return buildSuggestionsSuccess(allResults);
            } else {
              return buildNoSuggestions(context);
            }
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }

  Widget buildNoSuggestions(context) => Center(
        child: Text(
          AppLocalizations.of(context)!.noSuggestions,
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      );

  Widget buildSuggestionsSuccess(Iterable<CloudPoll> suggestions) =>
      ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions.elementAt(index);
          final queryText = suggestion.title.substring(0, query.length);
          final remainingText = suggestion.title.substring(query.length);
          return ListTile(
              onTap: () {
                query = suggestion.title;
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
