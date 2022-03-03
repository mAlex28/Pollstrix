import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollstrix/models/poll_model.dart';

class User {
  String uid;
  String email;
  String username;
  String fname;
  String lname;
  String imageUrl;
  String bio;
  List<Poll>? polls;

  User(this.uid, this.email, this.imageUrl, this.username, this.fname,
      this.lname, this.bio);

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'username': username,
        'fname': fname,
        'lname': lname,
        'bio': bio,
        'profilePhoto': imageUrl,
      };

  User.fromData(Map<String, dynamic> data)
      : uid = data['uid'],
        email = data['email'],
        username = data['username'],
        fname = data['first_name'],
        lname = data['last_name'],
        bio = data['bio'],
        imageUrl = data['imageUrl'];

  Stream<List<Poll?>> pollsSnapshots() => FirebaseFirestore.instance
      .collection('users/$uid/polls')
      .snapshots()
      .map(mapQueryPoll);

  Future<void> vote(Poll poll, int value) async {
    final ref = FirebaseFirestore.instance;

    await ref.collection('users/$uid/polls').doc(poll.id).set({
      'isAuth': poll.isAuth,
      'voteValue': value,
      'finished': false,
    });

    await ref.collection('polls').doc(poll.id).update({
      'voteCount': poll.voteCount! + 1,
      if (poll is ChoicePoll)
        'optionsVoteCount': poll.optionsVoteCount
          ..replaceRange(value, value + 1, [poll.optionsVoteCount[value] + 1])
    });

    await Future<void>.delayed(const Duration(seconds: 5));
    return ref.collection('users/$uid/polls').doc(poll.id).update({
      'finished': true,
    });
  }

  void dismiss(Poll poll) => FirebaseFirestore.instance
          .collection('users/$uid/polls')
          .doc(poll.id)
          .set({
        'dismissed': true,
      });
}
