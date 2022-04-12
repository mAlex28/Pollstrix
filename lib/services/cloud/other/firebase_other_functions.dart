import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/cloud_storage_exceptions.dart';

class FirebaseOtherFunctions {
  final reports = FirebaseFirestore.instance.collection('reports');
  final devices = FirebaseFirestore.instance.collection('devices');

  Future<void> sendReport(
      {required String pollId,
      required String userId,
      required String text}) async {
    try {
      await reports.add(
          {pollIdField: pollId, userIdField: userId, reportTextField: text});
    } catch (e) {
      throw CouldNotReportPollException();
    }
  }

  Future<void> saveDeviceId(
      {required String deviceId, required String userId}) async {
    try {
      await devices
          .doc(deviceId)
          .set({deviceIdField: deviceId, userIdField: userId});
    } catch (e) {
      throw CouldNotSaveDeviceId();
    }
  }

  Future<bool> checkIfTheCurrentDeviceIsRegistered(
      {required String deviceId}) async {
    try {
      final result =
          await devices.where(deviceIdField, isEqualTo: deviceId).get();

      if (result.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw CouldNotFindDeviceId();
    }
  }

  // singleton
  static final FirebaseOtherFunctions _shared =
      FirebaseOtherFunctions._sharedInstance();
  FirebaseOtherFunctions._sharedInstance();
  factory FirebaseOtherFunctions() => _shared;
}
