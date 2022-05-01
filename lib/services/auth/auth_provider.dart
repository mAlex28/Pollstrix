import 'package:pollstrix/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();

  // optionally return the current user
  AuthUser? get currentUser;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser(
      {required String email,
      required String password,
      required String displayName,
      required String firstName,
      required String lastName,
      required String imageUrl});

  Future<AuthUser> updateUser(
      {required String documentId,
      required String displayName,
      required String firstName,
      required String lastName,
      required String imageUrl,
      required String bio});

  Future<void> deleteUser({required String email, required String password});

  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> resetPassword({required String email});
  Future<void> forgotPassword({required String email});
  Future<AuthUser> signInWithGoogle();
}
