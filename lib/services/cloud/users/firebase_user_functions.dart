import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserFunctions {
  final users = FirebaseFirestore.instance.collection('users');

  // singleton
  static final FirebaseUserFunctions _shared =
      FirebaseUserFunctions._sharedInstance();
  FirebaseUserFunctions._sharedInstance();
  factory FirebaseUserFunctions() => _shared;
}
