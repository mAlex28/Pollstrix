import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:comment_box/comment/comment.dart';

class FeedbackPage extends StatefulWidget {
  final String pollID;
  final String userID;
  const FeedbackPage({Key? key, required this.pollID, required this.userID})
      : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late TextEditingController _feedbackTextController;
  List<dynamic> list = [];
  List<dynamic> userProfileImageList = [];
  late String getUser;

  @override
  void initState() {
    super.initState();
    _getFeedbackList();
    _feedbackTextController = TextEditingController();
  }

  @override
  void dispose() {
    _feedbackTextController.dispose();
    super.dispose();
  }

  _commentFeedbacks(uid, username, pid, feedback) async {
    await _firebaseFirestore.collection('feedbacks').doc().set(
      {
        'user': uid,
        'username': username,
        'pid': pid,
        'feedback': feedback,
        'createdAt': DateTime.now().toUtc()
      },
    );
  }

  _getFeedbackList() async {
    var user = [];

    // get all the feedback documents
    var snapshot = await _firebaseFirestore.collection('feedbacks').get();

    snapshot.docs.map((doc) {
      if (widget.pollID == doc.data()['pid']) {
        user.add(doc.data()['user']);
        list.add(doc.data());

        setState(() {});
      }
    }).toList();

    // get photoUrl of the users who has given feedbacks
    // var userImageslist = await _firebaseFirestore.collection('users').get();
    // userImageslist.docs.map((e) {
    //   if (user[i]) {}

    //   // var img = e.data()['imageUrl'];
    //   // if (img == "") {
    //   //   img =
    //   //       "https://lh3.googleusercontent.com/a-/AOh14GjRHcaendrf6gU5fPIVd8GIl1OgblrMMvGUoCBj4g=s400";
    //   // }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail =
        Provider.of<AuthenticationService>(context).getCurrentUserDisplayName();
    final currentUserImageUrl =
        Provider.of<AuthenticationService>(context).getCurrentUserImageUrl();

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseFirestore.collection('feedbacks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState != ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return CommentBox(
              userImage: currentUserImageUrl,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  for (var i = 0; i < list.length; i++)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
                      child: ListTile(
                        leading: Container(
                          height: 50.0,
                          width: 50.0,
                          decoration: const BoxDecoration(
                              color: kAccentColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                  "https://lh3.googleusercontent.com/a-/AOh14GjRHcaendrf6gU5fPIVd8GIl1OgblrMMvGUoCBj4g=s400")),
                        ),
                        title: Text(
                          list[i]['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(list[i]['feedback']),
                      ),
                    )
                ],
              ),
              labelText: 'Write a comment...',
              withBorder: true,
              errorText: 'Comment cannot be blank',
              sendButtonMethod: () async {
                if (formKey.currentState!.validate()) {
                  await _commentFeedbacks(widget.userID, currentUserEmail,
                      widget.pollID, _feedbackTextController.text);
                  setState(() {
                    list.clear();
                    _getFeedbackList();
                  });
                  _feedbackTextController.clear();
                  FocusScope.of(context).unfocus();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      CustomWidgets.customSnackbar(
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
