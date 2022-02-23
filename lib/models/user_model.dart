class User {
  String uid;
  String email;
  String username;
  String fname;
  String lname;
  String imageUrl;
  String bio;

  User(this.uid, this.email, this.imageUrl, this.username, this.fname,
      this.lname, this.bio);

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'username': username,
        'fname': fname,
        'lname': lname,
        'bio': bio,
        'profilePhoto': imageUrl,
      };

  User.fromData(Map<String, dynamic> data)
      : uid = data['uid'],
        email = data['email'],
        username = data['username'],
        fname = data['first_name'],
        lname = data['last_name'],
        bio = data['bio'],
        imageUrl = data['imageUrl'];
}
