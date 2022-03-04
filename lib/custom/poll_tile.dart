import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/polls.dart';
import 'package:pollstrix/models/poll_model.dart';

class PollTile extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doc;

  const PollTile({Key? key, required this.doc}) : super(key: key);

  @override
  _PollTileState createState() => _PollTileState();
}

class _PollTileState extends State<PollTile> {
  double option1 = 1.0;
  double option2 = 1.0;
  double option3 = 1.0;
  double option4 = 1.0;

  String user = "king@mail.com";

  Map usersWhoVoted = {
    'sam@mail.com': 3,
    'mike@mail.com': 4,
    'john@mail.com': 1,
    'kenny@mail.com': 1
  };
  String creator = "eddy@mail.com";

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Polls(
              children: (widget.doc.data() as dynamic)['choices'].map((choice) {
                return Polls.options(title: '$choice', value: option1);
              }).toList(),
              question: Text(
                (widget.doc.data() as dynamic)['title'],
                style: const TextStyle(fontSize: 16),
              ),
              voteData: usersWhoVoted,
              currentUser: this.user,
              creatorID: this.creator,
              onVote: (choice) {
                setState(() {
                  this.usersWhoVoted[this.user] = choice;
                });
                if (choice == 1) {
                  setState(() {
                    option1 += 1.0;
                  });
                }
                if (choice == 2) {
                  setState(() {
                    option2 += 1.0;
                  });
                }
                if (choice == 3) {
                  setState(() {
                    option3 += 1.0;
                  });
                }
                if (choice == 4) {
                  setState(() {
                    option4 += 1.0;
                  });
                }
              },
              onVoteBackgroundColor: Colors.blue,
              leadingBackgroundColor: Colors.blue,
              backgroundColor: Colors.white,
              allowCreatorVote: false,
              userChoice: usersWhoVoted[this.user],
            ),
            // ChoicePollAction(choicePoll: poll),
          ],
        ),
      ),
    );
  }
}
