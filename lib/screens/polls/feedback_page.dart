import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/polls/firebase_poll_functions.dart';
import 'package:pollstrix/utilities/custom/comment.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';
import 'package:pollstrix/services/theme_service.dart';

class FeedbackPage extends StatefulWidget {
  final String pollID;
  final String userID;

  const FeedbackPage({Key? key, required this.pollID, required this.userID})
      : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late final FirebasePollFunctions _pollService;
  String? get currentUserEmail =>
      AuthService.firebase().currentUser!.displayName;
  String? get currentUserImage => AuthService.firebase().currentUser!.imageUrl;

  final formKey = GlobalKey<FormState>();
  late TextEditingController _feedbackTextController;
  List<dynamic> list = [];
  List<dynamic> userProfileImageList = [];
  final DateFormat formatter = DateFormat('EEE, MMM d');

  @override
  void initState() {
    _pollService = FirebasePollFunctions();
    _feedbackTextController = TextEditingController();
    _getFeedbackList();
    super.initState();
  }

  @override
  void dispose() {
    _feedbackTextController.dispose();
    super.dispose();
  }

  // add new feedback
  _commentFeedbacks(username, pid, feedback) async {
    await _pollService.feedbacks.doc().set(
      {
        displayNameField: username,
        pollIdField: pid,
        feedbackField: feedback,
        createdAtField: DateTime.now().toUtc()
      },
    );
  }

  _getFeedbackList() async {
    // get all the feedback documents
    var snapshot = await _pollService.feedbacks.get();

    snapshot.docs.map((doc) {
      if (widget.pollID == doc.data()[pollIdField]) {
        list.add(doc.data());

        setState(() {});
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _pollService.feedbacks.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState != ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return CommentBox(
              userImage: currentUserImage,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  for (var i = 0; i < list.length; i++)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
                      child: ListTile(
                        trailing: Text(
                            formatter.format(
                                list[i][createdAtField].toDate().toLocal()),
                            style: kCaptionTextStyle.copyWith(fontSize: 12)),
                        title: Text(
                          list[i][displayNameField],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(list[i][feedbackField]),
                      ),
                    )
                ],
              ),
              labelText: 'Write a comment...',
              withBorder: true,
              errorText: 'Comment cannot be blank',
              sendButtonMethod: () async {
                if (formKey.currentState!.validate()) {
                  await _commentFeedbacks(currentUserEmail, widget.pollID,
                      _feedbackTextController.text.trim());

                  setState(() {
                    list.clear();
                    _getFeedbackList();
                  });

                  _feedbackTextController.clear();

                  FocusScope.of(context).unfocus();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackbar.customSnackbar(
                          backgroundColor: Colors.red,
                          content: 'Oops..Something went wrong..'));
                }
              },
              formKey: formKey,
              commentController: _feedbackTextController,
              backgroundColor: Theme.of(context).backgroundColor,
              textColor: Colors.grey,
              sendWidget:
                  const Icon(Icons.send_sharp, size: 30, color: kAccentColor),
            );
          }
        },
      ),
    );
  }
}
