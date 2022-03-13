import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/polls.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';
import 'package:pollstrix/screens/feedback_page.dart';
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
  late TextEditingController _reportTextController;
  late DateTime _currentDate;
  bool _changePollType = false;

  bool isLiked = false;
  bool isDisliked = false;

  @override
  void initState() {
    super.initState();
    _reportTextController = TextEditingController();
    _currentDate = DateTime.now();
    _isLiked();
    _isDisliked();
  }

  @override
  void dispose() {
    _reportTextController.dispose();
    super.dispose();
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

  _showReportDialog(
      {required String uid,
      required String pid,
      required BuildContext context}) {
    final size = MediaQuery.of(context).size;

    showDialog<Widget>(
        context: context,
        builder: (BuildContext builder) {
          return AlertDialog(
            title: const Text(
              'Report a poll',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            backgroundColor: Colors.white,
            content: SizedBox(
              height: 140,
              width: 300,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Please state why you are reporting this poll clearly!',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  TextField(
                    controller: _reportTextController,
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    minLines: 3,
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade500, width: 1.5),
                        ),
                        hintStyle: const TextStyle(fontSize: 14.0),
                        hintText: 'Write something here!'),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    if (_reportTextController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          CustomWidgets.customSnackbar(
                              content: 'Cannot submit an empty report'));
                    } else {
                      await _firebaseFirestore.collection('reports').doc().set({
                        'uid': uid,
                        'pid': pid,
                        'report': _reportTextController.text.trim(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          CustomWidgets.customSnackbar(
                              content: 'Successfully submited'));
                    }

                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  // Show pop up menu on the card when hamburger is clicked
  _showPopupMenu(BuildContext context, TapDownDetails details,
      {required String uid, required String pid}) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          details.globalPosition.dx,
          details.globalPosition.dy,
          details.globalPosition.dx,
          details.globalPosition.dy),
      items: [
        const PopupMenuItem<String>(child: Text('Report'), value: '1'),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == null) return;

      if (value == '1') {
        _showReportDialog(uid: uid, pid: pid, context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<AuthenticationService>(context).getCurrentUserEmail();
    final String currentUserID =
        Provider.of<AuthenticationService>(context).getCurrentUID();
    final usersWhoVoted = (widget.doc.data() as dynamic)['voteData'].asMap();
    final creater = (widget.doc.data() as dynamic)['creatorEmail'];
    final DateTime endDate = (widget.doc.data() as dynamic)['endDate'].toDate();
    final DateTime startDate =
        (widget.doc.data() as dynamic)['startDate'].toDate();

    // calculate remaining time left for the poll
    final range = endDate.difference(startDate).inDays;

    return endDate.isAfter(_currentDate)
        ? Card(
            // margin: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DecoratedBox(
                          decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Ends In: $range days',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                  fontSize: 12.0),
                            ),
                          )),
                      GestureDetector(
                          child: const Icon(
                            Icons.more_vert_rounded,
                            size: 16.0,
                          ),
                          onTapDown: (details) => _showPopupMenu(
                              context, details,
                              uid: currentUserID, pid: widget.doc.id))
                    ],
                  ),
                  currentUser == creater || _changePollType
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
                            setState(() {
                              _changePollType = true;
                            });
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
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.grey)),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FeedbackPage(
                                        pollID: widget.doc.id,
                                        userID: currentUser!,
                                      )))),
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
