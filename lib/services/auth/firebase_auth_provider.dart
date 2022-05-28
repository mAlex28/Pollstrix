import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pollstrix/services/auth/auth_exceptions.dart';
import 'package:pollstrix/services/auth/auth_provider.dart';
import 'package:pollstrix/services/auth/auth_user.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pollstrix/services/cloud/users/firebase_user_functions.dart';

class FirebaseAuthProvider implements AuthProvider {
  final FirebaseUserFunctions _userService = FirebaseUserFunctions();

  @override
  Future<AuthUser> createUser(
      {required String email,
      required String password,
      required String displayName,
      required String firstName,
      required String lastName,
      required String imageUrl}) async {
    try {
      final instance =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await instance.user!.updateDisplayName(displayName);
      await instance.user!.updatePhotoURL(imageUrl);

      // create user in the cloudstore
      await _userService.createUserInFirebase(
          userId: instance.user!.uid,
          email: email,
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          imageUrl: imageUrl);

      final user = currentUser;

      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
        apiKey: 'AIzaSyBNEhcwHGg4XoSrWrPWg1LwZpYgfmoMPMo',
        appId: '1:630918106032:web:a36cc8f6d094035f4d2475',
        messagingSenderId: '630918106032',
        projectId: 'pollstrix-ec795',
        authDomain: 'pollstrix-ec795.firebaseapp.com',
        storageBucket: 'pollstrix-ec795.appspot.com',
        measurementId: 'G-Q0Z2QZ54QK',
      ));
    } else {
      await Firebase.initializeApp();
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    final instance = FirebaseAuth.instance;
    final user = instance.currentUser;

    if (user != null) {
      await instance.sendPasswordResetEmail(email: email);
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final instance = FirebaseAuth.instance;

    try {
      await instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication?.accessToken,
          idToken: googleSignInAuthentication?.idToken);

      late UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(authProvider);
      } else {
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      var displayName = userCredential.user!.displayName;
      var photoURL = userCredential.user!.photoURL;

      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.updatePhotoURL(photoURL);

      // check if the user is already created an account using google
      var userExists =
          await _userService.users.doc(userCredential.user!.uid).get();

      if (!userExists.exists) {
        await _userService.createUserInFirebase(
            userId: userCredential.user!.uid,
            email: userCredential.user!.email,
            displayName: displayName,
            firstName: '',
            lastName: '',
            imageUrl: photoURL);
      }

      final user = currentUser;

      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw AccountExistsWithDifferentCredentialsException();
      } else if (e.code == 'invalid-credential') {
        throw InvalidCredentialsException();
      } else {
        throw CouldNotSignInWithGoogleException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> updateUser(
      {required String documentId,
      required String displayName,
      required String firstName,
      required String lastName,
      required String imageUrl,
      required String bio}) async {
    try {
      final instance = FirebaseAuth.instance.currentUser!;

      await instance.updateDisplayName(displayName);
      await instance.updatePhotoURL(imageUrl);
      await instance.reload();

      await _userService.updateUserInFirebase(
          documentId: documentId,
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          imageUrl: imageUrl,
          bio: bio);

      final user = currentUser;

      if (user != null) {
        return user;
      } else {
        throw CouldNotUpdateUserException();
      }
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  @override
  Future<void> deleteUser(
      {required String email, required String password}) async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);

      var result = await user!.reauthenticateWithCredential(credential);

      await _userService.deleteUserInFirebase(documentId: result.user!.uid);
      await result.user!.delete();
    } catch (e) {
      throw GenericAuthException();
    }
  }
}
