import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthenticationService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // auth.User? _userFromFirebase(auth.User? user) {
  //   if (user == null) {
  //     return null;
  //   }
  //   return  auth.User? (user.uid, user.email);
  // }

  Stream<auth.User?>? get user {
    return _firebaseAuth.authStateChanges();
  }

  String getCurrentUID() {
    return _firebaseAuth.currentUser!.uid;
  }

  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  getProfileImage() {
    if (_firebaseAuth.currentUser?.photoURL != null) {
      return Image.network(
        _firebaseAuth.currentUser!.photoURL!,
        height: 100,
        width: 100,
      );
    } else {
      return const Icon(Icons.account_circle_rounded, size: 100);
    }
  }

  Future<auth.User?> signInWithEmailAndPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    auth.User? user;
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = credential.user;
    } on auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: 'Error loging in. Try again'));
    }

    return user;
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

  Future<auth.User?> createUserWithEmailAndPassword(
      {required String fname,
      required String lname,
      required String username,
      required String email,
      required String password,
      required BuildContext context}) async {
    auth.User? user;
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      await updateUsername(username, credential.user!);

      await FirebaseFirestore.instance.collection('users').add({
        'first_name': fname,
        'last_name': lname,
        'usernmae': username,
        'email': email,
        'password': password,
      });

      user = credential.user;
    } on auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: 'Error creating account.'));
    }

    return user;
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
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Email sent'),
          content: const Text('Please check your inbox to reset the password'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"))
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

  // update username
  Future updateUsername(String name, auth.User currentUser) async {
    await currentUser.updateDisplayName(name);
    await currentUser.reload();
  }

  Future convertUserWithEmail(
      String email, String password, String name) async {
    final currentUser = _firebaseAuth.currentUser;

    final credential =
        auth.EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.linkWithCredential(credential);
    await updateUsername(name, currentUser);
  }

  Future convertWithGoogle() async {
    final currentUser = _firebaseAuth.currentUser;
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth =
        await account!.authentication;
    final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    await currentUser!.linkWithCredential(credential);
    await updateUsername(googleSignIn.currentUser!.displayName!, currentUser);
  }
}
