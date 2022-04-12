import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePollFunctions {
  final poll = FirebaseFirestore.instance.collection('users');

  // create
  // retrive
  // delete
  // like
  // comment

  // singleton
  static final FirebasePollFunctions _shared =
      FirebasePollFunctions._sharedInstance();
  FirebasePollFunctions._sharedInstance();
  factory FirebasePollFunctions() => _shared;
}
