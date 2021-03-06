import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  String? id;
  String? title;
  List<String>? options;
  Timestamp? createdAt;
  bool? isAuth;
  int? voteValue;
  int? voteCount;
  bool? dismissed;
  bool? finished;

  Poll({
    this.id,
    this.title,
    this.options,
    this.createdAt,
    this.isAuth = false,
    this.voteValue,
    this.voteCount = 0,
    this.dismissed = false,
    this.finished = true,
  });

  Poll.fromFirestore(DocumentSnapshot doc)
      : id = doc.id,
        title = doc.get('title') as String,
        options = doc.get('options') != null
            ? (doc.get('options') as List<dynamic>).cast<String>()
            : [],
        createdAt = doc.get('createdAt') as Timestamp,
        isAuth = doc.get('isAuth') as bool,
        voteValue = doc.get('voteValue') as int,
        voteCount = doc.get('voteCount') as int,
        dismissed = doc.get('dismissed') as bool,
        finished = doc.get('finished') as bool;

  Map<String, dynamic> genericToJson() => {
        'title': title,
        'options': options,
        'createdAt': createdAt,
        'voteCount': voteCount,
      };

  Map<String, dynamic> userToJson() => {
        'isAuth': isAuth,
        'voteValue': voteValue,
        'dismissed': dismissed,
        'finished': finished,
      };

  @override
  String toString() => '$id $title poll';
}

class ChoicePoll extends Poll {
  List<int> optionsVoteCount;

  ChoicePoll({
    required String id,
    required String title,
    required List<String> options,
    required Timestamp createdAt,
    required bool isAuth,
    required int voteValue,
    required int voteCount,
    required bool dismissed,
    required bool finished,
    required this.optionsVoteCount,
  }) : super(
          id: id,
          title: title,
          options: options,
          createdAt: createdAt,
          isAuth: isAuth,
          voteValue: voteValue,
          voteCount: voteCount,
          dismissed: dismissed,
          finished: finished,
        );

  ChoicePoll.fromPoll(Poll poll, {required this.optionsVoteCount})
      : super(
          id: poll.id,
          title: poll.title,
          options: poll.options,
          createdAt: poll.createdAt,
          isAuth: poll.isAuth,
          voteValue: poll.voteValue,
          voteCount: poll.voteCount,
          dismissed: poll.dismissed,
          finished: poll.finished,
        );

  int get totalCount =>
      optionsVoteCount.fold(0, (prev, element) => prev + element);

  @override
  ChoicePoll.fromFirestore(DocumentSnapshot doc)
      : optionsVoteCount = doc.get('optionsVoteCount') != null
            ? (doc.get('optionsVoteCount') as List<dynamic>).cast<int>()
            : [],
        super.fromFirestore(doc);

  @override
  Map<String, dynamic> genericToJson() => {
        ...super.genericToJson(),
        'optionsVoteCount': optionsVoteCount,
      };

  @override
  String toString() {
    return '${options!.length} options';
  }
}

List<Poll?> mapQueryPoll(QuerySnapshot query) {
  return query.docs.map((e) {
    if (e.get("dissmissed") != null && e.get('dissmieed') as bool) {
      return null;
    }
    return ChoicePoll.fromFirestore(e);
  }).toList();
}

Stream<List<Poll?>> popularPollListSnapshots() => FirebaseFirestore.instance
        .collection('polls')
        .orderBy('voteCount', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      return query.docs.map((e) {
        if (e.get("dissmissed") != null && e.get('dissmieed') as bool) {
          return null;
        }

        return ChoicePoll.fromFirestore(e);
      }).toList();
    });

Stream<List<Poll?>> latestPollListSnapshots() => FirebaseFirestore.instance
        .collection('polls')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      return query.docs.map((e) {
        if (e.get("dissmissed") != null && e.get('dissmieed') as bool) {
          return null;
        }

        return ChoicePoll.fromFirestore(e);
      }).toList();
    });
