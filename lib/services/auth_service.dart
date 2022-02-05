import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_widgets.dart';
import 'package:pollstrix/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthenticationService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  User? _userFromFirebase(auth.User? user) {
    if (user == null) {
      return null;
    }
    return User(user.uid, user.email);
  }

  Stream<User?>? get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<dynamic> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return _userFromFirebase(credential.user);
    } on auth.FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<auth.User?> signInWithGoogle({required BuildContext context}) async {
    auth.User? user;

    if (kIsWeb) {
      auth.GoogleAuthProvider authProvider = auth.GoogleAuthProvider();

      try {
        final auth.UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    }

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      try {
        final auth.UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        user = userCredential.user;
      } on auth.FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
              content:
                  'The account already exists with a different credential.'));
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
              CustomWidgets.customSnackbar(
                  content:
                      'Error occurred while accessing credentials. Try again.'));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
            content: 'Error occurred using Google Sign-In. Try again.'));
      }

      return user;
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    return _userFromFirebase(credential.user);
  }

  Future<void> signOut({required BuildContext context}) async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error Signing out. Try again.'));
    }
  }
}

//  static Future<void> signOut({required BuildContext context}) async {
//     final GoogleSignIn googleSignIn = GoogleSignIn();

//     try {
//       if (!kIsWeb) {
//         await googleSignIn.signOut();
//       }
//       await FirebaseAuth.instance.signOut();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         Authentication.customSnackBar(
//           content: 'Error signing out. Try again.',
//         ),
//       );
//     }}
