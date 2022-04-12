import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/cloud_storage_exceptions.dart';
import 'package:pollstrix/services/cloud/polls/cloud_poll.dart';

class FirebasePollFunctions {
  final polls = FirebaseFirestore.instance.collection('polls');

  // TODO: create

  //  TODO: vote

  //  TODO: like
  Future<void> likePoll(
      {required String userId,
      required int likes,
      required String pollId}) async {
    try {} catch (e) {
      throw CouldNotDeletePollException();
    }
  }

  //  TODO: comment

  // retrive all polls posted by the current user as a stream
  Stream<Iterable<CloudPoll>> getAllPolls({required String currentUserId}) =>
      polls.snapshots().map((events) => events.docs
          .map((doc) => CloudPoll.fromSnapshot(doc))
          .where((note) => note.creatorId == currentUserId));

  // retrive all polls posted by the current user as a iterable future
  Future<Iterable<CloudPoll>> getNotes({required String currentUserId}) async {
    try {
      return await polls
          .where(creatorIdField, isEqualTo: currentUserId)
          .get()
          .then(
              (value) => value.docs.map((doc) => CloudPoll.fromSnapshot(doc)));
    } catch (e) {
      throw CouldNotGetAllPollsException();
    }
  }

  // delete
  Future<void> deletePoll({required String documentId}) async {
    try {
      await polls.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeletePollException();
    }
  }

  // singleton
  static final FirebasePollFunctions _shared =
      FirebasePollFunctions._sharedInstance();
  FirebasePollFunctions._sharedInstance();
  factory FirebasePollFunctions() => _shared;
}
