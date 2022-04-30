import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/cloud_storage_exceptions.dart';

class FirebaseUserFunctions {
  final users = FirebaseFirestore.instance.collection('users');

  // create user
  Future<void> createUserInFirebase({
    required String userId,
    required String email,
    required String displayName,
    required String firstName,
    required String lastName,
    required String imageUrl,
  }) async {
    try {
      const bio = 'Hey there';

      await users.doc(userId).set({
        emailField: email,
        displayNameField: displayName,
        firstNameField: firstName,
        lastNameField: lastName,
        imageUrlField: imageUrl,
        bioField: bio,
        likedPollsField: [],
        dislikedPollsField: []
      }, SetOptions(merge: true));
    } catch (e) {
      throw CouldNotCreateUserException();
    }
  }

  // update user
  Future<void> updateUserInFirebase(
      {required String documentId,
      required String displayName,
      required String firstName,
      required String lastName,
      required String imageUrl,
      required String bio}) async {
    try {
      await users.doc(documentId).update({
        displayNameField: displayName,
        firstNameField: firstName,
        lastNameField: lastName,
        imageUrlField: imageUrl,
        bioField: bio
      });
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  // delete user
  Future<void> deleteUserInFirebase({
    required String documentId,
  }) async {
    try {
      await users.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteUserException();
    }
  }

  // singleton
  static final FirebaseUserFunctions _shared =
      FirebaseUserFunctions._sharedInstance();
  FirebaseUserFunctions._sharedInstance();
  factory FirebaseUserFunctions() => _shared;
}
