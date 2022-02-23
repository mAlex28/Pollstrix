import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  User user = User("", "", "", "", "", "", "");
  bool isUpdating = false;
  String imageUrl = '';

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  _getUserProfile() async {
    final profile =
        await Provider.of<AuthenticationService>(context).getCurrentUser();

    if (profile.photoURL != null) {
      setState(() {
        imageUrl = profile.photoURL;
      });
    } else {
      imageUrl = '';
    }
  }

  @override
  void didChangeDependencies() {
    _getUserProfile();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthenticationService>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isUpdating = true;
                  });

                  authData
                      .updateUserDetails(
                          fname: _fnameController.text,
                          lname: _lnameController.text,
                          username: _usernameController.text,
                          imageUrl: imageUrl,
                          bio: _bioController.text,
                          context: context)
                      .then((value) {
                    setState(() {
                      isUpdating = false;
                    });
                  });
                },
                icon: const Icon(Icons.done_rounded))
          ],
        ),
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Center(
                child: SingleChildScrollView(
                    child: isUpdating
                        ? Column(
                            children: const [
                              CircularProgressIndicator(),
                              Text('Updating user data...')
                            ],
                          )
                        : FutureBuilder(
                            future: _getUserData(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                _fnameController.text = user.fname;
                                _lnameController.text = user.lname;
                                _usernameController.text = user.username;
                                _emailController.text = user.email;
                                _bioController.text = user.bio;
                              }

                              return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    UserImage(
                                        onFileChanged: (imageUrl) {
                                          setState(() {
                                            this.imageUrl = imageUrl;
                                          });
                                        },
                                        isProfile: true),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Neumorphic(
                                          margin: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 2,
                                              bottom: 4),
                                          style: NeumorphicStyle(
                                            depth: NeumorphicTheme.embossDepth(
                                                context),
                                            boxShape: const NeumorphicBoxShape
                                                .stadium(),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 18),
                                          child: TextField(
                                            minLines: 2,
                                            controller: _bioController,
                                            decoration:
                                                const InputDecoration.collapsed(
                                                    hintText: "About you...."),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Neumorphic(
                                          margin: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 2,
                                              bottom: 4),
                                          style: NeumorphicStyle(
                                            depth: NeumorphicTheme.embossDepth(
                                                context),
                                            boxShape: const NeumorphicBoxShape
                                                .stadium(),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 18),
                                          child: TextField(
                                            controller: _fnameController,
                                            decoration: const InputDecoration
                                                    .collapsed(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Neumorphic(
                                          margin: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 2,
                                              bottom: 4),
                                          style: NeumorphicStyle(
                                            depth: NeumorphicTheme.embossDepth(
                                                context),
                                            boxShape: const NeumorphicBoxShape
                                                .stadium(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Neumorphic(
                                          margin: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 2,
                                              bottom: 4),
                                          style: NeumorphicStyle(
                                            depth: NeumorphicTheme.embossDepth(
                                                context),
                                            boxShape: const NeumorphicBoxShape
                                                .stadium(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Neumorphic(
                                          margin: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 2,
                                              bottom: 4),
                                          style: NeumorphicStyle(
                                            depth: NeumorphicTheme.embossDepth(
                                                context),
                                            boxShape: const NeumorphicBoxShape
                                                .stadium(),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 18),
                                          child: TextField(
                                            readOnly: true,
                                            onTap: () =>
                                                authData.updateUserEmail(
                                                    _emailController.text,
                                                    context),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            controller: _emailController,
                                            decoration:
                                                const InputDecoration.collapsed(
                                                    hintText:
                                                        "Enter your email"),
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 14,
                                                        horizontal: 18),
                                                    child: TextButton(
                                                        onPressed: () =>
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/reset-password'),
                                                        child: const Text(
                                                          'Change password',
                                                        )))
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 14,
                                                        horizontal: 18),
                                                    child: TextButton(
                                                        onPressed: () {
                                                          showDialog<Widget>(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      builder) {
                                                                return AlertDialog(
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              context),
                                                                          child:
                                                                              const Text("No")),
                                                                      TextButton(
                                                                          onPressed: () => authData.deleteAccount(context).then((value) => Navigator.pushNamed(
                                                                              context,
                                                                              '/')),
                                                                          child:
                                                                              const Text("Yes"))
                                                                    ],
                                                                    content:
                                                                        const Text(
                                                                            'Are you sure you want to delete the account?'));
                                                              });
                                                        },
                                                        child: Text(
                                                          'Delete Account',
                                                          style: TextStyle(
                                                              color: Colors.red
                                                                  .shade600),
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
        user.bio = value.data()!['bio'];
      });
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
