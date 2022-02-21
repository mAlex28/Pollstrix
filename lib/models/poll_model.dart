import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  String id;
  String title;
  List<String> options;
  Timestamp createdAt;
  Timestamp endDate;
  int dates;
  int voteCount;
  bool finished;

  Poll({
    required this.id,
    required this.title,
    required this.options,
    required this.createdAt,
    required this.endDate,
    required this.dates,
    required this.voteCount,
    required this.finished,
  });
}
