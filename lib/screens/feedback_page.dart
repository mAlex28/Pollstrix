import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/polls.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';
import 'package:pollstrix/services/auth_service.dart';
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

  List filedata = [
    {
      'name': 'Adeleye Ayodeji',
      'pic': 'https://picsum.photos/300/30',
      'message': 'I love to code'
    },
    {
      'name': 'Biggi Man',
      'pic': 'https://picsum.photos/300/30',
      'message': 'Very cool'
    },
    {
      'name': 'Biggi Man',
      'pic': 'https://picsum.photos/300/30',
      'message': 'Very cool'
    },
    {
      'name': 'Biggi Man',
      'pic': 'https://picsum.photos/300/30',
      'message': 'Very cool'
    },
  ];

  @override
  void initState() {
    super.initState();
    _feedbackTextController = TextEditingController();
  }

  @override
  void dispose() {
    _feedbackTextController.dispose();
    super.dispose();
  }

  _commentFeedbacks(uid, pid, feedback) async {
    await _firebaseFirestore.collection('feedbacks').doc().set(
      {
        'uid': uid,
        'pid': pid,
        'feedback': feedback,
        'createdAt': DateTime.now().toUtc()
      },
    );
  }

  Future<List<dynamic>> _getFeedbackList() async {
    var convertToAList;
    await _firebaseFirestore.collection('feedbacks').doc().get().then((value) {
      return convertToAList = value.data();
    });

    return convertToAList;
  }

  Widget commentChild(data) {
    return ListView(
      children: [
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () async {
                  // Display the image in large form.
                  print("Comment Clicked");
                },
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(data[i]['pic'] + "$i")),
                ),
              ),
              title: Text(
                data[i]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[i]['message']),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Container(
        child: CommentBox(
          userImage:
              Provider.of<AuthenticationService>(context).getProfileImage(),
          child: commentChild(_getFeedbackList()),
          labelText: 'Write a comment...',
          withBorder: false,
          errorText: 'Comment cannot be blank',
          sendButtonMethod: () async {
            if (formKey.currentState!.validate()) {
              await _commentFeedbacks(
                  widget.userID, widget.pollID, _feedbackTextController.text);
              setState(() {});
              _feedbackTextController.clear();
              FocusScope.of(context).unfocus();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  CustomWidgets.customSnackbar(
                      content: 'Oops..Something went wrong..'));
            }
          },
          formKey: formKey,
          commentController: _feedbackTextController,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          sendWidget:
              const Icon(Icons.send_sharp, size: 30, color: Colors.blue),
        ),
      ),
    );
  }
}
