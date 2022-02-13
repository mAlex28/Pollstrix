import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:pollstrix/custom/image_selection.dart';
import 'package:pollstrix/models/user_model.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User user = User("", "", "", "", "", "");

  String imageUrl = '';

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Color _textColor(BuildContext context) {
    if (NeumorphicTheme.isUsingDark(context)) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  String? _formFieldsValidator(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _emailFieldValidator(String? text) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);

    if (text == null || text.trim().isEmpty) {
      return 'This field is required';
    } else if (!regExp.hasMatch(text.trim())) {
      return 'Invalid email address';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.done_rounded))
          ],
        ),
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Center(
                child: SingleChildScrollView(
                    child: FutureBuilder(
                        future: _getUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            _fnameController.text = user.fname;
                            _lnameController.text = user.lname;
                            _usernameController.text = user.username;
                            _emailController.text = user.email;
                          }

                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                UserImage(
                                    onFileChanged: (imageUrl) {
                                      setState(() {});
                                    },
                                    isProfile: true),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Neumorphic(
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 8, top: 2, bottom: 4),
                                      style: NeumorphicStyle(
                                        depth: NeumorphicTheme.embossDepth(
                                            context),
                                        boxShape:
                                            const NeumorphicBoxShape.stadium(),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 18),
                                      child: TextField(
                                        controller: _fnameController,
                                        decoration:
                                            const InputDecoration.collapsed(
                                                hintText:
                                                    "Enter your first name"),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Neumorphic(
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 8, top: 2, bottom: 4),
                                      style: NeumorphicStyle(
                                        depth: NeumorphicTheme.embossDepth(
                                            context),
                                        boxShape:
                                            const NeumorphicBoxShape.stadium(),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 18),
                                      child: TextField(
                                        controller: _lnameController,
                                        decoration:
                                            const InputDecoration.collapsed(
                                                hintText:
                                                    "Enter your last name"),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Neumorphic(
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 8, top: 2, bottom: 4),
                                      style: NeumorphicStyle(
                                        depth: NeumorphicTheme.embossDepth(
                                            context),
                                        boxShape:
                                            const NeumorphicBoxShape.stadium(),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 18),
                                      child: TextField(
                                        controller: _usernameController,
                                        decoration:
                                            const InputDecoration.collapsed(
                                                hintText:
                                                    "Enter your username"),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Neumorphic(
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 8, top: 2, bottom: 4),
                                      style: NeumorphicStyle(
                                        depth: NeumorphicTheme.embossDepth(
                                            context),
                                        boxShape:
                                            const NeumorphicBoxShape.stadium(),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 18),
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: _emailController,
                                        decoration:
                                            const InputDecoration.collapsed(
                                                hintText: "Enter your email"),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                        horizontal: 18),
                                                child: TextButton(
                                                    onPressed: () =>
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/reset-password'),
                                                    child: const Text(
                                                      'Forgot password',
                                                    )))
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                        horizontal: 18),
                                                child: TextButton(
                                                    onPressed: () {},
                                                    child: Text(
                                                      'Delete Account',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .red.shade600),
                                                    )))
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ]);
                        })))));
  }

  _getUserData() async {
    final uid = Provider.of<AuthenticationService>(context).getCurrentUID();
    // final profileImg =
    //       Provider.of<AuthenticationService>(context).getProfileImage();
    try {
      await Provider.of<FirebaseFirestore>(context)
          .collection('users')
          .doc(uid)
          .get()
          .then((value) {
        user.fname = value.data()!['first_name'];
        user.lname = value.data()!['last_name'];
        user.email = value.data()!['email'];
        user.username = value.data()!['username'];
      });

      // final ref =
      //     storage.FirebaseStorage.instance.ref(user.imageUrl).getDownloadURL();

    } catch (e) {
      CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text('$e'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      );
    }
  }
}
