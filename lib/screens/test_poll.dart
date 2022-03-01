import 'package:flutter/material.dart';
import 'package:polls/polls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class TestPollPage extends StatefulWidget {
  const TestPollPage({Key? key}) : super(key: key);

  @override
  State<TestPollPage> createState() => _TestPollPageState();
}

class _TestPollPageState extends State<TestPollPage> {
  double option1 = 1.0;
  double option2 = 0.0;
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Polls(
                children: [
                  Polls.options(title: 'Cairo', value: option1),
                  Polls.options(title: 'Mecca', value: option2),
                  Polls.options(title: 'Denmark', value: option3),
                  Polls.options(title: 'Mogadishu', value: option4),
                ],
                onVoteBackgroundColor: Colors.blue,
                leadingBackgroundColor: Colors.blue,
                backgroundColor: Colors.white,
                question: const Text(
                  'What is the capital of egypt?',
                  style: TextStyle(fontSize: 18),
                ),
                voteData: usersWhoVoted,
                userChoice: usersWhoVoted[this.user],
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
                }),
            SizedBox(
              height: 20,
            ),
            Polls(
                children: [
                  Polls.options(title: 'Lago', value: option1),
                  Polls.options(title: 'Shakespear', value: option2),
                  Polls.options(title: 'Voldermort', value: option3),
                  Polls.options(title: 'Harry', value: option4),
                ],
                onVoteBackgroundColor: Colors.blue,
                leadingBackgroundColor: Colors.blue,
                backgroundColor: Colors.white,
                question: const Text(
                  'What is the name of the main antagonist in the Shakespeare play Othello?',
                  style: TextStyle(fontSize: 18),
                ),
                voteData: usersWhoVoted,
                userChoice: usersWhoVoted[this.user],
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
                }),
          ]),
    );
  }

  Future _getData() async {
    // final CollectionReference pollList =
    //     Provider.of<FirebaseFirestore>(context).collection('polls');

    try {
      return await Provider.of<FirebaseFirestore>(context)
          .collection('polls')
          .get();
    } catch (e) {
      const Center(child: CircularProgressIndicator());
    }
  }
}





// FutureBuilder(
//         future: _getData(),
//         builder: (context, AsyncSnapshot<dynamic> snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             print('done ');

//             if (!snapshot.hasData) {
//               print('no data');
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else {
//               print(snapshot.data);
//               print('done and has data');
//               return ListView.builder(itemBuilder: (_, index) {
//                 print('list');
//                 return Card(
//                   child: ListTile(
//                       title: Text(
//                           (snapshot.data![index].data() as dynamic)['title'])),
//                 );
//               });
//             }
//           } else {
//             print('connecting');
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       )