import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pollstrix/services/auth/auth_exceptions.dart';
import 'package:pollstrix/services/auth/auth_provider.dart';
import 'package:pollstrix/services/auth/auth_user.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
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
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        var displayName = userCredential.user!.displayName;
        var photoURL = userCredential.user!.photoURL;

        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.updatePhotoURL(photoURL);
        // await userCredential.user!.reload();

        final user = currentUser;
        if (user != null) {
          return user;
        } else {
          throw UserNotLoggedInAuthException();
        }
      } else {
        throw GenericAuthException();
      }
    } on FirebaseAuthException catch (e) {
      throw CouldNotSignInWithGoogle();
    } catch (e) {
      throw GenericAuthException();
    }
  }
}
