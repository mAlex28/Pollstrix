import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_widgets.dart';
import 'package:pollstrix/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthenticationService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? _userFromFirebase(auth.User? user) {
    if (user == null) {
      return null;
    }
    return User(user.uid, user.email);
  }

  Stream<User?>? get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<User?> signInWithEmailAndPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return _userFromFirebase(credential.user);
    } on auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: 'Error loging in. Try again'));
    }
  }

  Future<User?> signInWithGoogle({required BuildContext context}) async {
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
      return _userFromFirebase(user);
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      {required String fname,
      required String lname,
      required String username,
      required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      await FirebaseFirestore.instance.collection('users').add({
        'first_name': fname,
        'last_name': lname,
        'usernmae': username,
        'email': email,
        'password': password,
      });

      return _userFromFirebase(credential.user);
    } on auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: 'Error creating account.'));
    }
  }

  Future<void> signOut({required BuildContext context}) async {
    try {
      if (!kIsWeb) {
        // android and ios google sign out
        googleSignIn.isSignedIn().then((value) async {
          if (value) {
            await googleSignIn.signOut();
          }
        });
      }
      // other sign out methods
      await _firebaseAuth.signOut();
    } on auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error Signing out. Try again.'));
    }
  }

  Future<void> resetPassword(
      {required String email, required BuildContext context}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Email sent'),
          content: Text('Please check your inbox to reset the password'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("OK"))
          ],
        ),
      );
    } on auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error sending email. Try again.'));
    }
  }
}
