import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final urlImage = "assets/images/avatar.png";

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
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar.customSnackbar(
                backgroundColor: Colors.red,
                content:
                    'Error occurred while accessing credentials. Try again.'));
      }
    }

    //TODO: #1 check if the google user is already registered

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
          ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackbar.customSnackbar(
                  backgroundColor: Colors.red,
                  content:
                      'The account already exists with a different credential.'));
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackbar.customSnackbar(
                  backgroundColor: Colors.red,
                  content:
                      'Error occurred while accessing credentials. Try again.'));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar.customSnackbar(
                backgroundColor: Colors.red,
                content: 'Error occurred using Google Sign-In. Try again.'));
      }
    }

    return user!.uid;
  }

  // update username
  Future updateUserProfile(String name, User currentUser, {photoURL}) async {
    await currentUser.updateDisplayName(name);
    await currentUser.updatePhotoURL(photoURL);
    await currentUser.reload();
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
}
