import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';

// NOTE removed: password and uid fields
// NOTE renamed: username into displayName and changed fields into snake case

@immutable
class CloudUser {
  final String userId;
  final String email;
  final String displayName;
  final String firstName;
  final String lastName;
  final dynamic imageUrl;
  final String bio;
  final List<String> likedPolls;
  final List<String> dislikedPolls;

  const CloudUser(
      {required this.userId,
      required this.email,
      required this.displayName,
      required this.firstName,
      required this.lastName,
      required this.imageUrl,
      required this.bio,
      required this.likedPolls,
      required this.dislikedPolls});

  CloudUser.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : userId = snapshot.id,
        email = snapshot.data()[emailField] as String,
        displayName = snapshot.data()[displayNameField] as String,
        firstName = snapshot.data()[firstNameField] as String,
        lastName = snapshot.data()[lastNameField] as String,
        imageUrl = snapshot.data()[imageUrlField],
        bio = snapshot.data()[bioField] as String,
        likedPolls = snapshot.data()[likedPollsField],
        dislikedPolls = snapshot.data()[dislikedPollsField];
}
