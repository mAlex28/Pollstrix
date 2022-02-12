import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:pollstrix/custom/image_selection.dart';
import 'package:pollstrix/models/user_model.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

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
  TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  String? _passwordFieldValidator(String? text) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);

    if (text == null || text.trim().isEmpty) {
      return 'This field is required';
    } else if (!regExp.hasMatch(text.trim())) {
      return 'Password should be 8 characters with mix of 1 uppercase, 1 lower case, 1 digit and 1 special character';
    }

    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                            _emailController.text = user.email;
                          }

                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                UserImage(onFileChanged: (imageUrl) {
                                  setState(() {
                                    this.imageUrl = imageUrl;
                                  });
                                }),
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
                                        controller: _emailController,
                                        decoration:
                                            const InputDecoration.collapsed(
                                                hintText: "Enter your email"),
                                      ),
                                    )
                                  ],
                                ),
                              ]);
                        })))));
  }

  _getUserData() async {
    final uid = Provider.of<AuthenticationService>(context).getCurrentUID();

    var result =
        Provider.of<FirebaseFirestore>(context).collection('users').doc(uid);
    print(result.get());
    // await Provider.of<FirebaseFirestore>(context)
    //     .collection('users')
    //     .doc(uid)
    //     .get()
    //     .then((value) {
    //   print(value.data());
    //   // user.fname = value['first_name'];
    //   // user.lname = value['last_name'];
    //   // user.email = value['email'];
    //   // user.imageUrl = value['imageUrl'];
    //   // user.username = value['username'];
    // });
  }
}
