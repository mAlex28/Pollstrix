// internals are never gonna change upon initialization - @immutable
// this class and all subclasses will be @immutable
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String userId;
  final String email;
  final String displayName;
  final String? imageUrl;
  final bool isEmailVerified;
  const AuthUser(
      {required this.userId,
      required this.email,
      required this.displayName,
      required this.imageUrl,
      required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) => AuthUser(
      userId: user.uid,
      email: user.email!,
      displayName: user.displayName!,
      imageUrl: user.photoURL,
      isEmailVerified: user.emailVerified);
}
