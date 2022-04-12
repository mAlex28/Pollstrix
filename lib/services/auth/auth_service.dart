import 'package:pollstrix/services/auth/auth_provider.dart';
import 'package:pollstrix/services/auth/auth_user.dart';
import 'package:pollstrix/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> resetPassword({required String email}) =>
      provider.resetPassword(email: email);

  @override
  Future<void> forgotPassword({required String email}) =>
      provider.forgotPassword(email: email);

  @override
  Future<AuthUser> signInWithGoogle() => provider.signInWithGoogle();
}