import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';

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

  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser!.email;
  }

  String? getCurrentUserDisplayName() {
    return _firebaseAuth.currentUser!.displayName;
  }

  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  String? getCurrentUserImageUrl() {
    return _firebaseAuth.currentUser!.photoURL;
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

  Future<String> downlaodDefaultAvatarFromStorage() async {
    try {
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('user/profile/avatar.png');

      var downloadUrl = await ref.getDownloadURL();

      return downloadUrl.toString();
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signInWithEmailAndPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    User? user;
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    user = credential.user;

    return user!.uid;
  }

  Future<String> getDeviceIdentifier() async {
    String deviceIdentifier = "unknown";
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
      // create a unique identifier for web
      deviceIdentifier = webBrowserInfo.vendor! +
          webBrowserInfo.userAgent! +
          webBrowserInfo.hardwareConcurrency.toString();
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;
        deviceIdentifier = androidDeviceInfo.androidId!;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        deviceIdentifier = iosDeviceInfo.identifierForVendor!;
      }
    }

    return deviceIdentifier;
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
        ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
            backgroundColor: Colors.red,
            content: 'Error occurred while accessing credentials. Try again.'));
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

        var displayName = userCredential.user!.displayName;
        var photoURL = userCredential.user!.photoURL;

        await _firebaseFirestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'imageUrl': userCredential.user!.photoURL,
          'first_name': '',
          'last_name': '',
          'username': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'password': '',
          'bio': 'Hello there!',
          'likedPolls': [],
          'dislikedPolls': []
        }, SetOptions(merge: true));

        var deviceId = getDeviceIdentifier();
        await _firebaseFirestore
            .collection('deviceIDs')
            .doc(deviceId.toString())
            .set({'deviceID': deviceId, 'uid': userCredential.user!.uid},
                SetOptions(merge: true));

        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.updatePhotoURL(photoURL);
        await userCredential.user!.reload();

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
              backgroundColor: Colors.red,
              content:
                  'The account already exists with a different credential.'));
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
              CustomWidgets.customSnackbar(
                  backgroundColor: Colors.red,
                  content:
                      'Error occurred while accessing credentials. Try again.'));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
            backgroundColor: Colors.red,
            content: 'Error occurred using Google Sign-In. Try again.'));
      }
    }

    return user!.uid;
  }

// create new user
  Future<String>? createUserWithEmailAndPassword(
      {required String fname,
      required String lname,
      required String username,
      required String email,
      required String password,
      required var imageUrl,
      required var deviceId,
      required BuildContext context}) async {
    User? user;
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      final firstName = toBeginningOfSentenceCase(fname);
      final lastName = toBeginningOfSentenceCase(lname);

      await _firebaseFirestore
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'imageUrl': imageUrl,
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'password': password,
        'bio': 'Hello there!',
        'likedPolls': [],
        'dislikedPolls': []
      }, SetOptions(merge: true));

      await _firebaseFirestore.collection('deviceIDs').doc(deviceId).set(
          {'deviceID': deviceId, 'uid': credential.user!.uid},
          SetOptions(merge: true));

      await credential.user!.updateDisplayName(username);
      await credential.user!.updatePhotoURL(imageUrl);
      await credential.user!.reload();
      user = credential.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: 'Error creating account.'));
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
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: 'Error creating account.'));
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
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red,
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
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Email sent'),
          content: const Text('Please check your inbox to reset the password'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"))
              ],
            )
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red,
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
      await _firebaseFirestore.collection('users').doc(currentUser.uid).update({
        'email': email,
      });

      await currentUser.updateEmail(email).then((value) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
              title: const Text('Email updated'),
              content: const Text('Email changed. Please re-login'),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"))
                  ],
                )
              ]),
        );
      });
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      FocusManager.instance.primaryFocus?.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.message.toString()));
    } catch (e) {
      Navigator.pop(context);
      FocusManager.instance.primaryFocus?.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red,
          content: 'Error sending email. Try again.'));
    }
    // await currentUser.reload();
  }

  // delete user account
  Future deleteAccount(BuildContext context) async {
    try {
      await _firebaseAuth.currentUser!.delete();
      // redirect the user to login page
      Navigator.pushNamed(context, '/login');
      await _firebaseAuth.currentUser!.reload();

      // get the data related to the current user to achieve it
      await _firebaseFirestore
          .collection('users')
          .doc(getCurrentUID())
          .get()
          .then((value) {
        _firebaseFirestore
            .collection('achievedUsers')
            .doc(getCurrentUID())
            .set(value.data()!, SetOptions(merge: true));
      });

      // delete the data related to the current logged in user from firestore
      await _firebaseFirestore
          .collection('users')
          .doc(getCurrentUID())
          .delete();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red,
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
      final currentUser = getCurrentUID();

      var listOfChoices = {};

      for (var i = 0; i < choices!.length; i++) {
        listOfChoices.addAll({
          i.toString(): {'title': choices[i], 'votes': 0}
        });
      }

      await _firebaseFirestore.collection('polls').doc().set({
        'uid': currentUser,
        'creatorEmail': getCurrentUserEmail(),
        'title': title,
        'choices': listOfChoices,
        'createdAt': createdTime,
        'startDate': startDate,
        'endDate': endDate,
        'finished': false,
        'voteCount': 0,
        'voteData': [],
        'likes': 0,
        'dislikes': 0,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red,
          content: 'Error creating a poll. Try again.'));
    }
  }

  Future onVote(
      {required BuildContext context,
      required String userId,
      required int selectedOption,
      required Map<String, dynamic> choices,
      required String pid}) async {
    try {
      // ignore: prefer_typing_uninitialized_variables
      var totalVotes;
      // ignore: prefer_typing_uninitialized_variables
      var voteDetails;

      await _firebaseFirestore.collection('polls').doc(pid).get().then((value) {
        totalVotes = value.data()!['voteCount'];
        voteDetails = value.data()!['voteData'];

        choices.entries.map((e) {
          if (int.parse(e.key) == (selectedOption - 1)) {
            e.value['votes'] = e.value['votes'] + 1;
            return;
          }
        }).toList();

        voteDetails.add({'uid': userId, 'option': selectedOption});

        _firebaseFirestore.collection('polls').doc(pid).update({
          'voteCount': totalVotes + 1,
          'voteData': voteDetails,
          'choices': choices
        });
      });
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.message.toString()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.toString()));
    }
  }
}
