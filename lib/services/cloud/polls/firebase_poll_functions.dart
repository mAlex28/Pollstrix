import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/cloud_storage_exceptions.dart';
import 'package:pollstrix/services/cloud/polls/cloud_poll.dart';

class FirebasePollFunctions {
  final polls = FirebaseFirestore.instance.collection('polls');
  final feedbacks = FirebaseFirestore.instance.collection('feedbacks');
  final reports = FirebaseFirestore.instance.collection('reports');

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
        titleField: title,
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

  // vote
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

  //  TODO: like
  Future<void> likePoll(
      {required String userId,
      required int likes,
      required String pollId}) async {
    try {} catch (e) {
      throw CouldNotDeletePollException();
    }
  }

  // leave feedback
  Future<void> commentFeedbacks(
      {required String currentUserId,
      required String displayName,
      required String pollId,
      required String feedback}) async {
    try {
      await polls.add({
        userIdField: currentUserId,
        displayNameField: displayName,
        pollIdField: pollId,
        feedbackField: feedback,
        createdAtField: DateTime.now().toUtc()
      });
    } catch (e) {
      throw CouldNotLeaveFeedbackException();
    }
  }

  //  TODO:retrive all feedbacks
  Future getCommentedFeedbacks(
      {required String currentUserId, required String pollId}) async {
    var user = [];
    final documents = await feedbacks.get();

    documents.docs.map((doc) {
      if (pollId == doc.data()[pollIdField]) {
        user.add(doc.data()[userIdField]);
      }
    });
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

  // report poll
  Future<void> reportPoll(
      {required String userId,
      required String pollId,
      required String text}) async {
    try {
      await reports.add({
        userIdField: userId,
        pollIdField: pollId,
        reportTextField: text,
      });
    } catch (e) {
      throw CouldNotReportPollException();
    }
  }

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
