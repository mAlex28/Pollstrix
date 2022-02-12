class User {
  String uid;
  String email;
  String username;
  String fname;
  String lname;
  String imageUrl;

  User(this.uid, this.email, this.imageUrl, this.username, this.fname,
      this.lname);

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'username': username,
        'fname': fname,
        'lname': lname,
        'profilePhoto': imageUrl,
      };

  User.fromData(Map<String, dynamic> data)
      : uid = data['uid'],
        email = data['email'],
        username = data['username'],
        fname = data['first_name'],
        lname = data['last_name'],
        imageUrl = data['imageUrl'];
}
