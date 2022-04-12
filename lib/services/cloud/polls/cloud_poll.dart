import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';

// NOTE removed: creatorEmail
// NOTE renamed: field names in snake case and user_id to creator_id

@immutable
class CloudPoll {
  final String documentId;
  final String creatorId;
  final String title;
  final Timestamp createdAt;
  final Timestamp startDate;
  final Timestamp endDate;
  final int voteCount;
  final int likes;
  final int dislikes;
  final bool isFinished;
  final Map<String, dynamic> choices;
  final List<Map<String, dynamic>> voteData;

  const CloudPoll(
      {required this.documentId,
      required this.creatorId,
      required this.title,
      required this.createdAt,
      required this.startDate,
      required this.endDate,
      this.voteCount = 0,
      this.likes = 0,
      this.dislikes = 0,
      required this.isFinished,
      required this.choices,
      required this.voteData});

  CloudPoll.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        creatorId = snapshot.data()[creatorIdField],
        title = snapshot.data()[titleField] as String,
        createdAt = snapshot.data()[createdAtField],
        startDate = snapshot.data()[startDateField],
        endDate = snapshot.data()[endDateField],
        voteCount = snapshot.data()[voteCountField] as int,
        likes = snapshot.data()[likesField] as int,
        dislikes = snapshot.data()[dislikesField] as int,
        isFinished = snapshot.data()[isFinishedField] as bool,
        choices = snapshot.data()[choicesField],
        voteData = snapshot.data()[voteDataField];
}
