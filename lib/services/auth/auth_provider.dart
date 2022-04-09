import 'package:pollstrix/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();

  // optionally return the current user
  AuthUser? get currentUser;

  // common methods for all providers
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
}
