// login exceptions

class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// register exceptions

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// generic exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class CouldNotUpdateUserException implements Exception {}

// google exceptions

class CouldNotSignInWithGoogleException implements Exception {}

class AccountExistsWithDifferentCredentialsException implements Exception {}

class InvalidCredentialsException implements Exception {}
