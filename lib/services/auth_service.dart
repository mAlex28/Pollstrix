import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final urlImage = "assets/images/avatar.png";

  Stream<String> get onAuthStateChanges =>
      _firebaseAuth.authStateChanges().map((User? user) => user!.uid);

  String getCurrentUID() {
    return _firebaseAuth.currentUser!.uid;
  }

  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  getProfileImage() {
    if (_firebaseAuth.currentUser?.photoURL != null) {
      return NetworkImage(
        _firebaseAuth.currentUser!.photoURL!,
      );
    } else {
      return AssetImage(urlImage);
    }
  }

  Future<String?> signInWithEmailAndPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    User? user;
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = credential.user;
      return user!.uid;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: 'Error loging in. Try again'));
    }
  }

// login with google
  Future<String> signInWithGoogle({required BuildContext context}) async {
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
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

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      try {
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
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
    }

    return user!.uid;
  }

// create new user
  Future<String> createUserWithEmailAndPassword(
      {required String fname,
      required String lname,
      required String username,
      required String email,
      required String password,
      required String imageUrl,
      required BuildContext context}) async {
    User? user;
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      await updateUserProfile(username, credential.user!, photoURL: imageUrl);

      await _firebaseFirestore
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'imageUrl': imageUrl,
        'first_name': fname,
        'last_name': lname,
        'username': username,
        'email': email,
        'password': password,
        'bio': '',
      });

      user = credential.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: 'Error creating account.'));
    }

    return user!.uid;
  }

  // update user account
  Future updateUserDetails(
      {required String fname,
      required String lname,
      required String username,
      required String imageUrl,
      required BuildContext context,
      String? bio}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      await updateUserProfile(username, currentUser!, photoURL: imageUrl);

      await _firebaseFirestore.collection('users').doc(currentUser.uid).update({
        'imageUrl': imageUrl,
        'first_name': fname,
        'last_name': lname,
        'username': username,
        'bio': bio,
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: 'Error creating account.'));
    }
  }

// sign out
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
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error Signing out. Try again.'));
    }
  }

// reset password
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
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error sending email. Try again.'));
    }
  }

  // update username
  Future updateUserProfile(String name, User currentUser, {photoURL}) async {
    await currentUser.updateDisplayName(name);
    await currentUser.updatePhotoURL(photoURL);
    await currentUser.reload();
  }

  // update username
  Future updateUserEmail(String email, context) async {
    final currentUser = _firebaseAuth.currentUser!;
    try {
      await currentUser.updateEmail(email);

      showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Email sent'),
          content:
              const Text('Please check your inbox change the email address'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"))
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error sending email. Try again.'));
    }
    await currentUser.reload();
  }

  // delete user account
  Future deleteAccount(BuildContext context) async {
    try {
      await _firebaseAuth.currentUser!.delete();
      await _firebaseAuth.currentUser!.reload();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error sending email. Try again.'));
    }
  }

  Future convertUserWithEmail(
      String email, String password, String name) async {
    final currentUser = _firebaseAuth.currentUser;

    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.linkWithCredential(credential);
    await updateUserProfile(name, currentUser);
  }

  Future convertWithGoogle() async {
    final currentUser = _firebaseAuth.currentUser;
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth =
        await account!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    await currentUser!.linkWithCredential(credential);
    await updateUserProfile(
        googleSignIn.currentUser!.displayName!, currentUser);
  }

  Future post(
      {required String title,
      required List<String>? choices,
      required DateTime createdTime,
      required DateTime startDate,
      required DateTime endDate,
      required BuildContext context}) async {
    try {
      final currentUser = AuthenticationService().getCurrentUID();

      await _firebaseFirestore.collection('polls').doc().set({
        'uid': currentUser,
        'title': title,
        'choices': choices,
        'createdAt': createdTime,
        'startDate': startDate,
        'endDate': endDate,
      });

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomWidgets.customSnackbar(content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error creating a poll. Try again.'));
    }
  }
}
