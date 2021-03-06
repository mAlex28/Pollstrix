import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollstrix/extensions/string/string_extension.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/cloud_storage_exceptions.dart';
import 'package:pollstrix/services/cloud/polls/cloud_poll.dart';

class FirebasePollFunctions {
  final polls = FirebaseFirestore.instance.collection('polls');
  final feedbacks = FirebaseFirestore.instance.collection('feedbacks');
  final users = FirebaseFirestore.instance.collection('users');

  // create a new poll
  Future<CloudPoll> createPoll({
    required String currentUserId,
    required String title,
    required List<String>? choices,
    required DateTime createdTime,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // turn the list of choices into a map
      Map<String, dynamic> listOfChoices = {};
      for (var i = 0; i < choices!.length; i++) {
        listOfChoices.addAll({
          i.toString(): {titleField: choices[i], votesField: 0}
        });
      }

      final document = await polls.add({
        creatorIdField: currentUserId,
        titleField: title.capitalize(),
        createdAtField: createdTime.toUtc(),
        startDateField: startDate.toUtc(),
        endDateField: endDate.toUtc(),
        isFinishedField: false,
        voteCountField: 0,
        voteDataField: [],
        likesField: 0,
        dislikesField: 0,
        choicesField: listOfChoices
      });

      final fetchedPoll = await document.get();
      return CloudPoll(
          documentId: fetchedPoll.id,
          creatorId: currentUserId,
          title: title,
          createdAt: createdTime.toUtc(),
          startDate: startDate.toUtc(),
          endDate: endDate.toUtc(),
          isFinished: false,
          choices: listOfChoices,
          voteData: const []);
    } catch (e) {
      throw CouldNotCreatePollException();
    }
  }

  // vote a poll
  Future<void> votePoll(
      {required String userId,
      required int selectedOption,
      required Map<String, dynamic> choices,
      required String pollId}) async {
    try {
      await polls.doc(pollId).get().then((value) async {
        var totalVotes = value.data()![voteCountField];
        var voteDetails = value.data()![voteDataField];

        choices.entries.map((e) {
          if (int.parse(e.key) == (selectedOption - 1)) {
            e.value[votesField] = e.value[votesField] + 1;
            return;
          }
        }).toList();

        voteDetails.add({userIdField: userId, optionField: selectedOption});

        await polls.doc(pollId).update({
          voteCountField: totalVotes + 1,
          voteDataField: voteDetails,
          choicesField: choices
        });
      });
    } catch (e) {
      throw CouldNotVotePollException();
    }
  }

  // retrive all polls posted by every user with order by
  Stream<Iterable<CloudPoll>> getAllPolls(
          {required String orderBy, bool isDescending = false}) =>
      polls.orderBy(orderBy, descending: isDescending).snapshots().map(
          (events) => events.docs.map((doc) => CloudPoll.fromSnapshot(doc)));

  // retrive all polls posted by every user with where
  Stream<Iterable<CloudPoll>> getAllPollsWithWhere(
          {required dynamic fieldName, dynamic object}) =>
      polls.where(fieldName, isEqualTo: object).snapshots().map(
          (events) => events.docs.map((doc) => CloudPoll.fromSnapshot(doc)));

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

  // Get polls for search
  Stream<Iterable<CloudPoll>> searchForPolls({required String query}) => polls
      .where(titleField, isGreaterThanOrEqualTo: query)
      .where(titleField, isLessThan: query + 'z')
      .snapshots()
      .map((events) => events.docs.map((doc) => CloudPoll.fromSnapshot(doc)));

  // Stream functions
  Stream<Iterable<CloudPoll>> getAllPollsOfTheUser(
          {required String currentUserId}) =>
      polls.snapshots().map((events) => events.docs
          .map((doc) => CloudPoll.fromSnapshot(doc))
          .where((poll) => poll.creatorId == currentUserId));

  Stream<Iterable<CloudPoll>> getVotedPollsOfTheUser(
          {required String currentUserId, required int userSelectedOption}) =>
      polls
          .where(voteDataField, arrayContains: {
            userIdField: currentUserId,
            optionField: userSelectedOption
          })
          .snapshots()
          .map((events) =>
              events.docs.map((doc) => CloudPoll.fromSnapshot(doc)));

  // singleton
  static final FirebasePollFunctions _shared =
      FirebasePollFunctions._sharedInstance();
  FirebasePollFunctions._sharedInstance();
  factory FirebasePollFunctions() => _shared;
}
