import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudReport {
  final String reportId; // report id is the same as the documentId
  final String pollId;
  final String userId;
  final String reportText;

  const CloudReport(
      {required this.reportId,
      required this.pollId,
      required this.userId,
      required this.reportText});

  CloudReport.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : reportId = snapshot.id,
        pollId = snapshot.data()[pollIdField] as String,
        userId = snapshot.data()[userIdField] as String,
        reportText = snapshot.data()[reportTextField] as String;
}

@immutable
class CloudDeviceId {
  final String deviceId;
  final String userId;

  const CloudDeviceId({required this.deviceId, required this.userId});

  CloudDeviceId.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : deviceId = snapshot.id,
        userId = snapshot.data()[userIdField] as String;
}
