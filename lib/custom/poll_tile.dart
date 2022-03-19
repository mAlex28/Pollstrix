import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polls/polls.dart';
import 'package:pollstrix/custom/custom_charts.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';
import 'package:pollstrix/screens/feedback_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:toggle_switch/toggle_switch.dart';

class PollTile extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doc;

  const PollTile({Key? key, required this.doc}) : super(key: key);

  @override
  _PollTileState createState() => _PollTileState();
}

class _PollTileState extends State<PollTile> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late TextEditingController _reportTextController;
  late DateTime _currentDate;
  bool _changePollType = false;
  late bool _showBarChart;
  List<bool> isSelectedPoll = [true, false];
  final String currentUserID = AuthenticationService().getCurrentUID();
  List<dynamic> pollsWithLikes = [];

  bool isLiked = false;
  bool isDisliked = false;

  @override
  void initState() {
    _findLikedPollsOfTheUser();
    _reportTextController = TextEditingController();
    _currentDate = DateTime.now();
    _showBarChart = true;
    _checkFinishedStatus();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _reportTextController.dispose();
    super.dispose();
  }

  _findLikedPollsOfTheUser() async {
    List<dynamic> likedPolls = [];
    List<dynamic> pidList = [];

    // get a list of available pids
    await _firebaseFirestore.collection('polls').get().then((value) {
      value.docs.forEach((doc) {
        pidList.add(doc.id);
      });
    });

    await _firebaseFirestore
        .collection('users')
        .doc(currentUserID)
        .get()
        .then((value) {
      likedPolls = value.data()!['likedPolls'];

      setState(() {
        likedPolls.map((e) {
          if (pidList.contains(e)) {
            pollsWithLikes.add(e);
          }
        }).toList();
      });
    });
  }

  // check if the poll has ended and update the 'finished' status of the poll
  _checkFinishedStatus() async {
    final DateTime endDate = (widget.doc.data() as dynamic)['endDate'].toDate();
    if (endDate.isBefore(_currentDate)) {
      await _firebaseFirestore
          .collection('polls')
          .doc(widget.doc.id)
          .update({'finished': true});
    }
  }

  _like(
      {required int likes,
      required String pid,
      required String uid,
      required bool isPollLiked}) async {
    List<dynamic> likedPolls = [];

    if (isPollLiked) {
      likedPolls.clear();

      await _firebaseFirestore.collection('users').doc(uid).get().then((value) {
        likedPolls = value.data()!['likedPolls'];
        likedPolls.remove(pid);
      });

      await _firebaseFirestore
          .collection('polls')
          .doc(pid)
          .update({'likes': likes - 1});

      await _firebaseFirestore
          .collection('users')
          .doc(uid)
          .update({'likedPolls': likedPolls});

      setState(() {
        isLiked = false;
      });
    } else {
      likedPolls.clear();

      await _firebaseFirestore.collection('users').doc(uid).get().then((value) {
        likedPolls = value.data()!['likedPolls'];
        likedPolls.add(pid);
      });

      await _firebaseFirestore
          .collection('polls')
          .doc(pid)
          .update({'likes': likes + 1});

      await _firebaseFirestore
          .collection('users')
          .doc(uid)
          .update({'likedPolls': FieldValue.arrayUnion(likedPolls)});
      setState(() {
        isLiked = true;
      });
    }
  }

  _dislike(
      {required int dislikes,
      required String pid,
      required String uid,
      required bool isPollDisiked}) async {
    List<dynamic> dislikedPolls = [];

    if (isPollDisiked) {
      dislikedPolls.clear();

      await _firebaseFirestore.collection('users').doc(uid).get().then((value) {
        dislikedPolls = value.data()!['dislikedPolls'];
        dislikedPolls.remove(pid);
      });

      await _firebaseFirestore
          .collection('polls')
          .doc(pid)
          .update({'dislikes': dislikes - 1});

      await _firebaseFirestore
          .collection('users')
          .doc(uid)
          .update({'dislikedPolls': dislikedPolls});

      setState(() {
        isDisliked = false;
      });
    } else {
      dislikedPolls.clear();

      await _firebaseFirestore.collection('users').doc(uid).get().then((value) {
        dislikedPolls = value.data()!['dislikedPolls'];
        dislikedPolls.add(pid);
      });

      await _firebaseFirestore
          .collection('polls')
          .doc(pid)
          .update({'dislikes': dislikes + 1});

      await _firebaseFirestore
          .collection('users')
          .doc(uid)
          .update({'dislikedPolls': dislikedPolls});
      setState(() {
        isDisliked = true;
      });
    }
  }

// Show report dialog to report a poll
  _showReportDialog(
      {required String uid,
      required String pid,
      required BuildContext context}) {
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
                              backgroundColor: Colors.red,
                              content: 'Cannot submit an empty report'));
                    } else {
                      await _firebaseFirestore.collection('reports').doc().set({
                        'uid': uid,
                        'pid': pid,
                        'report': _reportTextController.text.trim(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          CustomWidgets.customSnackbar(
                              backgroundColor: Colors.green,
                              content: 'Successfully submited'));
                    }

                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  // Show delete poll dialog if the creator is current user and delte the item
  _deletePollDialog({required String pid, required BuildContext context}) {
    showDialog<Widget>(
        context: context,
        builder: (BuildContext builder) {
          return AlertDialog(
              title: const Text(
                'Delete poll',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("No")),
                TextButton(
                    onPressed: () async {
                      // delete the poll after confirmation
                      await _firebaseFirestore
                          .collection('polls')
                          .doc(pid)
                          .delete()
                          .whenComplete(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                            CustomWidgets.customSnackbar(
                                backgroundColor: Colors.green,
                                content: 'Successfully deleted'));
                        Navigator.of(context).pop();
                      }).onError((error, stackTrace) => ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(CustomWidgets.customSnackbar(
                                  backgroundColor: Colors.red,
                                  content:
                                      'Unkown error! Please try again later')));
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.red),
                    ))
              ],
              content:
                  const Text('Are you sure you want to delete this poll?'));
        });
  }

  // Show pop up menu on the card when hamburger is clicked
  _showPopupMenu(BuildContext context, TapDownDetails details,
      {required String? uid, required String pid, required String creator}) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          details.globalPosition.dx,
          details.globalPosition.dy,
          details.globalPosition.dx,
          details.globalPosition.dy),
      items: uid == creator
          ? [
              const PopupMenuItem<String>(child: Text('Report'), value: '1'),
              const PopupMenuItem<String>(
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  value: '2'),
            ]
          : [
              const PopupMenuItem<String>(child: Text('Report'), value: '1'),
            ],
      elevation: 8.0,
    ).then((value) {
      if (value == null) return;

      if (value == '1') {
        _showReportDialog(uid: uid!, pid: pid, context: context);
      } else if (value == '2') {
        _deletePollDialog(pid: pid, context: context);
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
    final creatorID = (widget.doc.data() as dynamic)['uid'];
    final DateTime endDate = (widget.doc.data() as dynamic)['endDate'].toDate();

    // calculate remaining time left for the poll
    final range = endDate.toLocal().difference(_currentDate.toLocal()).inDays;

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
                              uid: currentUserID,
                              pid: widget.doc.id,
                              creator: creatorID))
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
                            color: isLiked ||
                                    pollsWithLikes.contains(widget.doc.id)
                                ? Colors.lightBlue[600]
                                : Colors.grey,
                            tooltip: 'Thumbs up',
                            onPressed: () async {
                              await _like(
                                  likes:
                                      (widget.doc.data() as dynamic)['likes'],
                                  pid: widget.doc.id,
                                  uid: (widget.doc.data() as dynamic)['uid'],
                                  isPollLiked: isLiked);
                            },
                          ),
                          Text(((widget.doc.data() as dynamic)['likes'])
                              .toString()),
                          // IconButton(
                          //   icon: const Icon(
                          //     Icons.thumb_down_alt_rounded,
                          //     semanticLabel: 'Thumbs down',
                          //   ),
                          //   iconSize: 20,
                          //   color: isDisliked == false
                          //       ? Colors.grey
                          //       : Colors.lightBlue[600],
                          //   tooltip: 'Thumbs down',
                          //   onPressed: () {
                          // if (isDisliked) {
                          //   isDisliked = true;
                          //   await _removeLikeOrDislike(
                          //       (widget.doc.data() as dynamic)['dislikes'],
                          //       widget.doc.id,
                          //       (widget.doc.data() as dynamic)['uid'],
                          //       false);
                          // } else {
                          //   await _likeOrDislike(
                          //       (widget.doc.data() as dynamic)['dislikes'],
                          //       widget.doc.id,
                          //       (widget.doc.data() as dynamic)['uid'],
                          //       false);
                          // }
                          // },
                          // ),
                          // Text(((widget.doc.data() as dynamic)['dislikes'])
                          //     .toString()),
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
        : Card(
            // margin: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.blue[300],
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4))),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Ended on: ${DateFormat('dd-MM-yyyy').format(endDate.toLocal())}',
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
                              uid: currentUserID,
                              pid: widget.doc.id,
                              creator: creatorID))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 8),
                    child: Text((widget.doc.data() as dynamic)['title'],
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ToggleSwitch(
                        borderColor: const [Colors.blue],
                        borderWidth: 1,
                        minWidth: 40.0,
                        minHeight: 20.0,
                        initialLabelIndex: 1,
                        cornerRadius: 8.0,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.white,
                        inactiveFgColor: Colors.blue,
                        totalSwitches: 2,
                        icons: const [
                          Icons.bar_chart_rounded,
                          Icons.pie_chart_rounded,
                        ],
                        activeBgColors: const [
                          [Colors.blue],
                          [Colors.blue]
                        ],
                        iconSize: 19.0,
                        onToggle: (index) {
                          if (index == 1) {
                            setState(() {
                              _showBarChart = false;
                            });
                          } else {
                            setState(() {
                              _showBarChart = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  _showBarChart
                      ? BarChart(
                          data: (widget.doc.data() as dynamic)['choices']
                              .map((choice) {
                          return PollResults(choice['title'], choice['votes'],
                              charts.ColorUtil.fromDartColor(Colors.green));
                        }).toList())
                      : PieChart(
                          data: (widget.doc.data() as dynamic)['choices']
                              .map((choice) {
                          return PollResults(choice['title'], choice['votes'],
                              charts.ColorUtil.fromDartColor(Colors.green));
                        }).toList()),
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
                            color:
                                isLiked ? Colors.lightBlue[600] : Colors.grey,
                            tooltip: 'Thumbs up',
                            onPressed: () async {
                              await _like(
                                  likes:
                                      (widget.doc.data() as dynamic)['likes'],
                                  pid: widget.doc.id,
                                  uid: (widget.doc.data() as dynamic)['uid'],
                                  isPollLiked: isLiked);
                              // if (isLiked) {
                              //   isLiked = false;
                              //   await _removeLikeOrDislike(
                              //       (widget.doc.data() as dynamic)['likes'],
                              //       widget.doc.id,
                              //       (widget.doc.data() as dynamic)['uid'],
                              //       true);
                              // } else {
                              //   await _likeOrDislike(
                              //       (widget.doc.data() as dynamic)['likes'],
                              //       widget.doc.id,
                              //       (widget.doc.data() as dynamic)['uid'],
                              //       true);
                              // }
                            },
                          ),
                          Text(((widget.doc.data() as dynamic)['likes'])
                              .toString()),
                          // IconButton(
                          //   icon: const Icon(
                          //     Icons.thumb_down_alt_rounded,
                          //     semanticLabel: 'Thumbs down',
                          //   ),
                          //   iconSize: 20,
                          //   color: isDisliked == false
                          //       ? Colors.grey
                          //       : Colors.lightBlue[600],
                          //   tooltip: 'Thumbs down',
                          //   onPressed: () async {
                          // if (isDisliked) {
                          //   isDisliked = true;
                          //   await _removeLikeOrDislike(
                          //       (widget.doc.data() as dynamic)['dislikes'],
                          //       widget.doc.id,
                          //       (widget.doc.data() as dynamic)['uid'],
                          //       false);
                          // } else {
                          //   await _likeOrDislike(
                          //       (widget.doc.data() as dynamic)['dislikes'],
                          //       widget.doc.id,
                          //       (widget.doc.data() as dynamic)['uid'],
                          //       false);
                          // }
                          // setState(() {});
                          //   },
                          // ),
                          // Text(((widget.doc.data() as dynamic)['dislikes'])
                          //     .toString()),
                        ],
                      ),
                      TextButton(
                          child: const Text('View feedback',
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
          );
  }
}
