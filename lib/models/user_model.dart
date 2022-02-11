class User {
  final String uid;
  final String email;
  final String username;
  final String fname;
  final String lname;
  final String imageUrl;

  User(this.uid, this.email, this.imageUrl, this.username, this.fname,
      this.lname);

  // TODO: check whether the firebase store user id.
  // fix sign up image

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'username': username,
        'fname': fname,
        'lname': lname,
        'profilePhoto': imageUrl,
      };
}
