import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:polls/polls.dart';
import 'package:pollstrix/screens/polls/feedback_page.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/other/firebase_other_functions.dart';
import 'package:pollstrix/services/cloud/polls/cloud_poll.dart';
import 'package:pollstrix/services/cloud/polls/firebase_poll_functions.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/charts/custom_charts.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';
import 'package:toggle_switch/toggle_switch.dart';

class PollTile extends StatefulWidget {
  final CloudPoll doc;
  final List<CloudPoll> pollList;
  final int index;

  const PollTile(
      {Key? key,
      required this.doc,
      required this.pollList,
      required this.index})
      : super(key: key);

  @override
  _PollTileState createState() => _PollTileState();
}

class _PollTileState extends State<PollTile> {
  final FirebasePollFunctions _pollService = FirebasePollFunctions();
  final FirebaseOtherFunctions _reportService = FirebaseOtherFunctions();
  String get currentUserId => AuthService.firebase().currentUser!.userId;

  late TextEditingController _reportTextController;
  late DateTime _currentDate;
  late bool _showBarChart;

  bool _hasUserVoted = false;
  bool isLiked = false;
  bool isDisliked = false;

  @override
  void initState() {
    super.initState();
    _reportTextController = TextEditingController();
    _currentDate = DateTime.now();
    _showBarChart = true;
    _findLikedPollsOfTheUser();
    _checkFinishedStatus();
    _checkUserVoteStatus();
  }

  @override
  void dispose() {
    // _reportTextController.dispose();
    super.dispose();
  }

  //find polls that are liked by the user and show them in blue colour
  _findLikedPollsOfTheUser() async {
    List<dynamic> likedPolls = [];

    await _pollService.users.doc(currentUserId).get().then((value) {
      likedPolls = value.data()![likedPollsField];
      setState(() {
        likedPolls.map((e) {
          if (e == widget.doc.documentId) {
            isLiked = true;
          }
        }).toList();
      });
    });
  }

  // check if the poll has ended and update the 'finished' status of the poll
  _checkFinishedStatus() async {
    final DateTime endDate = widget.doc.endDate.toLocal();
    if (endDate.isBefore(_currentDate)) {
      await _pollService.polls
          .doc(widget.doc.documentId)
          .update({isFinishedField: true});
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

      await _pollService.users.doc(uid).get().then((value) {
        likedPolls = value.data()![likedPollsField];
        likedPolls.remove(pid);
      });

      await _pollService.polls.doc(pid).update({likesField: likes - 1});

      await _pollService.users.doc(uid).update({likedPollsField: likedPolls});

      setState(() {
        isLiked = false;
      });
    } else {
      likedPolls.clear();

      await _pollService.users.doc(uid).get().then((value) {
        likedPolls = value.data()![likedPollsField];
        likedPolls.add(pid);
      });

      await _pollService.polls.doc(pid).update({likesField: likes + 1});

      await _pollService.users
          .doc(uid)
          .update({likedPollsField: FieldValue.arrayUnion(likedPolls)});
      setState(() {
        isLiked = true;
      });
    }
  }

  // Show report dialog to report a poll
  _showReportDialog(
      {required String uid,
      required String pid,
      required BuildContext context}) async {
    await showDialog<Widget>(
        context: context,
        builder: (BuildContext builder) {
          return AlertDialog(
            title: const Text(
              'Report a poll',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            backgroundColor: Theme.of(context).backgroundColor,
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
                          CustomSnackbar.customSnackbar(
                              backgroundColor: Colors.red,
                              content: 'Cannot submit an empty report'));
                    } else {
                      try {
                        await _reportService.sendReport(
                            pollId: pid,
                            userId: uid,
                            text: _reportTextController.text.trim());

                        ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackbar.customSnackbar(
                                backgroundColor: Colors.green,
                                content: 'Successfully submited'));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackbar.customSnackbar(
                                backgroundColor: Colors.red,
                                content: 'Error! submitting report'));
                      }
                    }

                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  // Show delete poll dialog: if the creator is current user and delete the item
  _deletePollDialog(
      {required String pid, required BuildContext context}) async {
    await showDialog<Widget>(
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
                      try {
                        await _pollService.deletePoll(documentId: pid);
                        setState(() {
                          widget.pollList.removeAt(widget.index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackbar.customSnackbar(
                                backgroundColor: Colors.green,
                                content: 'Successfully deleted'));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackbar.customSnackbar(
                                backgroundColor: Colors.red,
                                content:
                                    'Unkown error! Please try again later'));
                      }
                      Navigator.of(context).pop();
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

  // Check if the current user has already voted on the poll
  _checkUserVoteStatus() async {
    List<dynamic> votedUsers = widget.doc.voteData;

    votedUsers.asMap().entries.map((e) {
      if (e.value[userIdField] == currentUserId) {
        setState(() {
          _hasUserVoted = true;
        });
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(360, 690),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);

    final usersWhoVoted = widget.doc.voteData.asMap();
    final creatorId = widget.doc.creatorId;
    final DateTime endDate = widget.doc.endDate.toLocal();
    final range = endDate.difference(_currentDate.toLocal()).inDays;

    return endDate.isAfter(_currentDate)
        ? Card(
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
                      Row(
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.only(right: 8.0),
                          //   child: GestureDetector(
                          //     child: Icon(
                          //       Icons.share,
                          //       color: Theme.of(context).iconTheme.color,
                          //       size: ScreenUtil().setSp(kSpacingUnit.w * 1.2),
                          //     ),
                          //     onTap: () async {
                          //       const url = "https://youtu.be/CNUBhb_cM6E";

                          //       await Share.share('Thedfsdfsdfs $url');
                          //     },
                          //   ),
                          // ),
                          Container(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: GestureDetector(
                                  child: Icon(
                                    Icons.more_vert_rounded,
                                    color: Theme.of(context).iconTheme.color,
                                    size: kIsWeb
                                        ? 20.0
                                        : ScreenUtil()
                                            .setSp(kSpacingUnit.w * 1.4),
                                  ),
                                  onTapDown: (details) => _showPopupMenu(
                                      context, details,
                                      uid: currentUserId,
                                      pid: widget.doc.documentId,
                                      creator: creatorId))),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(widget.doc.voteCount.toString() + ' votes',
                        style: const TextStyle(
                            fontSize: 12.0, color: Colors.grey)),
                  ),
                  currentUserId == creatorId || _hasUserVoted
                      ? Polls.viewPolls(
                          children: widget.doc.choices.entries.map((e) {
                            return Polls.options(
                                title: '${e.value[titleField]}',
                                value: (e.value[votesField]).toDouble());
                          }).toList(),
                          question: Text(widget.doc.title,
                              style: kIsWeb
                                  ? const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : kTitleTextStyle),
                          userChoice: usersWhoVoted[currentUserId],
                          onVoteBackgroundColor: Colors.blueGrey,
                          leadingBackgroundColor: kAccentColor,
                          backgroundColor: kAccentColor,
                        )
                      : Polls(
                          children: widget.doc.choices.entries.map((choice) {
                            return Polls.options(
                                title: '${choice.value['title']}',
                                value: (choice.value['votes']).toDouble());
                          }).toList(),
                          question: Text(widget.doc.title,
                              style: kIsWeb
                                  ? const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : kTitleTextStyle),
                          voteData: usersWhoVoted,
                          currentUser: currentUserId,
                          creatorID: creatorId,
                          userChoice: usersWhoVoted[currentUserId],
                          onVote: (choice) async {
                            try {
                              await _pollService.votePoll(
                                  userId: currentUserId,
                                  selectedOption: choice,
                                  choices: widget.doc.choices,
                                  pollId: widget.doc.documentId);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackbar.customSnackbar(
                                      content: 'Error voting',
                                      backgroundColor: Colors.red));
                            }
                            setState(() {
                              _hasUserVoted = true;
                            });
                          },
                          onVoteBackgroundColor: Colors.blue,
                          leadingBackgroundColor: kAccentColor,
                          backgroundColor: Theme.of(context).backgroundColor,
                          outlineColor: kAccentColor,
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
                            color:
                                isLiked ? kAccentColor : Colors.blueGrey[100],
                            tooltip: 'Thumbs up',
                            onPressed: () async {
                              await _like(
                                  likes: widget.doc.likes,
                                  pid: widget.doc.documentId,
                                  uid: currentUserId,
                                  isPollLiked: isLiked);
                            },
                          ),
                          Text(widget.doc.likes.toString()),
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
                                        pollID: widget.doc.documentId,
                                        userID: currentUserId,
                                      )))),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Card(
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
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: kIsWeb
                                ? 20.0
                                : ScreenUtil().setSp(kSpacingUnit.w * 1.2),
                          ),
                          onTapDown: (details) => _showPopupMenu(
                              context, details,
                              uid: currentUserId,
                              pid: widget.doc.documentId,
                              creator: creatorId))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 8),
                    child: Text(widget.doc.title,
                        style: kIsWeb
                            ? const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )
                            : kTitleTextStyle),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(widget.doc.voteCount.toString() + ' votes',
                            style: const TextStyle(
                                fontSize: 12.0, color: Colors.grey)),
                      ),
                      ToggleSwitch(
                        borderColor: const [Colors.blue],
                        borderWidth: 1,
                        minWidth: 40.0,
                        minHeight: 20.0,
                        initialLabelIndex: 1,
                        cornerRadius: 8.0,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Theme.of(context).backgroundColor,
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
                          data: widget.doc.choices.entries.map((choice) {
                          return PollResults(
                              choice.value['title'],
                              choice.value['votes'] ?? 0,
                              charts.ColorUtil.fromDartColor(Colors.green));
                        }).toList())
                      : PieChart(
                          data: widget.doc.choices.entries.map((choice) {
                          return PollResults(
                              choice.value['title'],
                              choice.value['votes'] ?? 0,
                              charts.ColorUtil.fromDartColor(
                                  const Color.fromARGB(255, 32, 96, 170)));
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
                                isLiked ? kAccentColor : Colors.blueGrey[100],
                            tooltip: 'Thumbs up',
                            onPressed: () async {
                              await _like(
                                  likes: widget.doc.likes,
                                  pid: widget.doc.documentId,
                                  uid: currentUserId,
                                  isPollLiked: isLiked);
                            },
                          ),
                          Text(widget.doc.likes.toString()),
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
                                        pollID: widget.doc.documentId,
                                        userID: currentUserId,
                                      )))),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
