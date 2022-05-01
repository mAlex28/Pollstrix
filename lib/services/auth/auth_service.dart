import 'package:pollstrix/services/auth/auth_provider.dart';
import 'package:pollstrix/services/auth/auth_user.dart';
import 'package:pollstrix/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser(
          {required String email,
          required String password,
          required String displayName,
          required String firstName,
          required String lastName,
          required String imageUrl}) =>
      provider.createUser(
          email: email,
          password: password,
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          imageUrl: imageUrl);

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

  @override
  Future<AuthUser> updateUser(
          {required String documentId,
          required String displayName,
          required String firstName,
          required String lastName,
          required String imageUrl,
          required String bio}) =>
      provider.updateUser(
          documentId: documentId,
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          imageUrl: imageUrl,
          bio: bio);

  @override
  Future<void> deleteUser({required String email, required String password}) =>
      provider.deleteUser(email: email, password: password);
}
