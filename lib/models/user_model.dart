class User {
  final String uid;
  final String? email;
  final String username;
  final String profile;

  User(this.uid, this.email, this.username, this.profile);

  // TODO: check whether the firebase store user id.
  // fix sign up image

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'username': username,
        'profilePhoto': profile,
      };
}
