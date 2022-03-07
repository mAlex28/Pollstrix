import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/polls.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class PollTile extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doc;

  const PollTile({Key? key, required this.doc}) : super(key: key);

  @override
  _PollTileState createState() => _PollTileState();
}

class _PollTileState extends State<PollTile> {
  final List<bool> isSelected = [false, false];
  late DateTime _currentDate;

  @override
  void initState() {
    _currentDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<AuthenticationService>(context).getCurrentUserEmail();

    final usersWhoVoted = (widget.doc.data() as dynamic)['voteData'].asMap();

    final DateTime endDate = (widget.doc.data() as dynamic)['endDate'].toDate();

    return endDate.isAfter(_currentDate)
        ? Card(
            margin: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Icon(
                        Icons.more_vert_rounded,
                        size: 15.0,
                      )
                    ],
                  ),
                  Polls(
                    children:
                        (widget.doc.data() as dynamic)['choices'].map((choice) {
                      return Polls.options(
                          title: '${choice['title']}',
                          value: (choice['votes']).toDouble());
                    }).toList(),
                    question: Text(
                      (widget.doc.data() as dynamic)['title'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    voteData: usersWhoVoted,
                    currentUser: currentUser,
                    creatorID: (widget.doc.data() as dynamic)['uid'],
                    userChoice: usersWhoVoted[currentUser],
                    onVote: (choice) {
                      if (choice == 1) {
                        setState(() {
                          Provider.of<AuthenticationService>(context).onVote(
                              context: context,
                              title: (widget.doc.data() as dynamic)['title'],
                              email: currentUser!,
                              selectedOption: choice,
                              pid: widget.doc.id);
                        });
                      }
                      if (choice == 2) {
                        setState(() {
                          Provider.of<AuthenticationService>(context).onVote(
                              context: context,
                              title: (widget.doc.data() as dynamic)['title'],
                              email: currentUser!,
                              selectedOption: choice,
                              pid: widget.doc.id);
                        });
                      }
                      if (choice == 3) {
                        setState(() {
                          Provider.of<AuthenticationService>(context).onVote(
                              context: context,
                              title: (widget.doc.data() as dynamic)['title'],
                              email: currentUser!,
                              selectedOption: choice,
                              pid: widget.doc.id);
                        });
                      }
                      if (choice == 4) {
                        setState(() {
                          Provider.of<AuthenticationService>(context).onVote(
                              context: context,
                              title: (widget.doc.data() as dynamic)['title'],
                              email: currentUser!,
                              selectedOption: choice,
                              pid: widget.doc.id);
                        });
                      }

                      setState(() {
                        usersWhoVoted[currentUser] = choice;
                      });
                    },
                    onVoteBackgroundColor: Colors.blue,
                    leadingBackgroundColor: Colors.blue,
                    backgroundColor: Colors.white,
                    // allowCreatorVote: false,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          // ToggleButtons(
                          //   children:const <Widget>[
                          //     Icon(Icons.thumb_up_rounded),
                          //     Icon(Icons.thumb_down_rounded)
                          //   ],
                          //   isSelected: isSelected,
                          //   color: Colors.grey,
                          //   selectedColor: Colors.lightBlue,
                          //   onPressed: (int index) {
                          //     setState(() {
                          //       for (int buttonIndex = 0;
                          //           buttonIndex < isSelected.length;
                          //           buttonIndex++) {
                          //         if (buttonIndex == index) {
                          //           isSelected[buttonIndex] =
                          //               !isSelected[buttonIndex];
                          //         } else {
                          //           isSelected[buttonIndex] = false;
                          //         }
                          //       }
                          //     });
                          //   },
                          // )

                          IconButton(
                            icon: const Icon(
                              Icons.thumb_up_alt_rounded,
                              semanticLabel: 'Thumbs up',
                            ),
                            iconSize: 20,
                            color: Colors.grey,
                            tooltip: 'Thumbs up',
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.thumb_down_alt_rounded,
                              semanticLabel: 'Thumbs down',
                            ),
                            iconSize: 20,
                            color: Colors.grey,
                            tooltip: 'Thumbs down',
                            onPressed: () {},
                          ),
                        ],
                      ),
                      TextButton(
                        child: const Text('Leave a feedback',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.grey)),
                        onPressed: () {/* ... */},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : const Card(
            child: Text('ended'),
          );
  }
}
