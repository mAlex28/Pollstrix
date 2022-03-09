import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollstrix/models/poll_model.dart';

class User {
  String? uid;
  String? email;
  String? username;
  String? firstName;
  String? lastName;
  String? imageUrl;
  String? bio;
  List<Poll>? polls;

  User(
      {this.uid,
      this.email,
      this.imageUrl,
      this.username,
      this.firstName,
      this.lastName,
      this.bio});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'username': username,
        'fname': firstName,
        'lname': lastName,
        'bio': bio,
        'profilePhoto': imageUrl,
      };

  User.fromMap(Map<String, dynamic> data, {String? uid})
      : uid = uid ?? '',
        email = data['email'] as String ?? '',
        username = data['username'] as String ?? '',
        firstName = data['first_name'] as String ?? '',
        lastName = data['last_name'] as String ?? '',
        bio = data['bio'] as String ?? '',
        imageUrl = data['imageUrl'] as String ?? '',
        polls = data['polls'] as List<Poll> ?? [];

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
