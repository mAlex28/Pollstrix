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
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late DateTime _currentDate;

  bool isLiked = false;
  bool isDisliked = false;

  @override
  void initState() {
    _currentDate = DateTime.now();
    _isLiked();
    _isDisliked();
  }

  Future<bool> _isLiked() async {
    List<dynamic> voted = [];
    final pollId = widget.doc.id;

    await _firebaseFirestore
        .collection('users')
        .doc((widget.doc.data() as dynamic)['uid'])
        .get()
        .then((value) {
      voted = value.data()!['likedPolls'];
    });

    setState(() {
      if (voted.contains(pollId)) {
        isLiked = true;
      } else {
        isLiked = false;
      }
    });

    return isLiked;
  }

  Future<bool> _isDisliked() async {
    List<dynamic> voted = [];
    final pollId = widget.doc.id;

    await _firebaseFirestore
        .collection('users')
        .doc((widget.doc.data() as dynamic)['uid'])
        .get()
        .then((value) {
      voted = value.data()!['dislikedPolls'];
      voted.contains(pollId);
    });

    setState(() {
      if (voted.contains(pollId)) {
        isDisliked = true;
      } else {
        isDisliked = false;
      }
    });

    return isDisliked;
  }

  _likeOrDislike(likesOrDislikes, pid, uid, bool liked) async {
    List<dynamic> voted = [];

    await _firebaseFirestore.collection('users').doc(uid).get().then((value) {
      if (liked) {
        voted = value.data()!['likedPolls'];
        voted.add(pid);
      } else {
        voted = value.data()!['dislikedPolls'];
        voted.add(pid);
      }
    });

    await _firebaseFirestore.collection('polls').doc(pid).update(liked
        ? {
            'likes': likesOrDislikes + 1,
          }
        : {
            'dislikes': likesOrDislikes + 1,
          });

    await _firebaseFirestore.collection('users').doc(uid).update(liked
        ? {'likedPolls': FieldValue.arrayUnion(voted)}
        : {
            'dislikedPolls': FieldValue.arrayUnion(voted),
          });

    setState(() {
      if (liked) {
        isLiked = true;
        isDisliked = false;
      } else {
        isDisliked = true;
        isLiked = false;
      }
    });
  }

  _removeLikeOrDislike(likesOrDislikes, pid, uid, bool liked) async {
    List<dynamic> voted = [];

    await _firebaseFirestore.collection('users').doc(uid).get().then((value) {
      if (liked) {
        voted = value.data()!['likedPolls'];
        voted.remove(pid);
      } else {
        voted = value.data()!['dislikedPolls'];
        voted.remove(pid);
      }
    });

    await _firebaseFirestore.collection('polls').doc(pid).update(liked
        ? {
            'likes': likesOrDislikes - 1,
          }
        : {
            'dislikes': likesOrDislikes - 1,
          });

    await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .update(liked ? {'likedPolls': voted} : {'dislikedPolls': voted});

    setState(() {
      if (liked) {
        isLiked = false;
      } else {
        isDisliked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<AuthenticationService>(context).getCurrentUserEmail();

    final usersWhoVoted = (widget.doc.data() as dynamic)['voteData'].asMap();
    final creater = (widget.doc.data() as dynamic)['creatorEmail'];
    final DateTime endDate = (widget.doc.data() as dynamic)['endDate'].toDate();

    return endDate.isAfter(_currentDate)
        ? Card(
            // margin: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
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
                  currentUser == creater
                      ? Polls.viewPolls(
                          children: (widget.doc.data() as dynamic)['choices']
                              .map((choice) {
                            return Polls.options(
                                title: '${choice['title']}',
                                value: (choice['votes']).toDouble());
                          }).toList(),
                          question: Text(
                            (widget.doc.data() as dynamic)['title'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          userChoice: usersWhoVoted[currentUser],
                          onVoteBackgroundColor: Colors.blue,
                          leadingBackgroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                        )
                      : Polls(
                          children: (widget.doc.data() as dynamic)['choices']
                              .map((choice) {
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
                          creatorID: creater,
                          userChoice: usersWhoVoted[currentUser],
                          onVote: (choice) async {
                            await Provider.of<AuthenticationService>(context,
                                    listen: false)
                                .onVote(
                                    context: context,
                                    email: currentUser!,
                                    selectedOption: choice,
                                    pid: widget.doc.id);
                          },
                          onVoteBackgroundColor: Colors.blue,
                          leadingBackgroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          allowCreatorVote: false),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.thumb_up_alt_rounded,
                              semanticLabel: 'Thumbs up',
                            ),
                            iconSize: 20,
                            color: isLiked == false
                                ? Colors.grey
                                : Colors.lightBlue[600],
                            tooltip: 'Thumbs up',
                            onPressed: () async {
                              if (isLiked) {
                                isLiked = false;
                                await _removeLikeOrDislike(
                                    (widget.doc.data() as dynamic)['likes'],
                                    widget.doc.id,
                                    (widget.doc.data() as dynamic)['uid'],
                                    true);
                              } else {
                                await _likeOrDislike(
                                    (widget.doc.data() as dynamic)['likes'],
                                    widget.doc.id,
                                    (widget.doc.data() as dynamic)['uid'],
                                    true);
                              }

                              setState(() {});
                            },
                          ),
                          Text(((widget.doc.data() as dynamic)['likes'])
                              .toString()),
                          IconButton(
                            icon: const Icon(
                              Icons.thumb_down_alt_rounded,
                              semanticLabel: 'Thumbs down',
                            ),
                            iconSize: 20,
                            color: isDisliked == false
                                ? Colors.grey
                                : Colors.lightBlue[600],
                            tooltip: 'Thumbs down',
                            onPressed: () async {
                              if (isDisliked) {
                                isDisliked = true;
                                await _removeLikeOrDislike(
                                    (widget.doc.data() as dynamic)['dislikes'],
                                    widget.doc.id,
                                    (widget.doc.data() as dynamic)['uid'],
                                    false);
                              } else {
                                await _likeOrDislike(
                                    (widget.doc.data() as dynamic)['dislikes'],
                                    widget.doc.id,
                                    (widget.doc.data() as dynamic)['uid'],
                                    false);
                              }
                              setState(() {});
                            },
                          ),
                          Text(((widget.doc.data() as dynamic)['dislikes'])
                              .toString()),
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
