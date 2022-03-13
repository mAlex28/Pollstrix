import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_textfield.dart';
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
  User user = User();
  bool isUpdating = false;
  String imageUrl = '';
  final _formKey = GlobalKey<FormState>();

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
        backgroundColor: Colors.white,
        body: Center(
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
                            _fnameController.text = user.firstName!;
                            _lnameController.text = user.lastName!;
                            _usernameController.text = user.username!;
                            _emailController.text = user.email!;
                            _bioController.text = user.bio!;
                          }

                          return Padding(
                              padding: const EdgeInsets.all(30),
                              child: Form(
                                  key: _formKey,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                        CustomTextField(
                                          minLines: 3,
                                          maxLines: 5,
                                          textEditingController: _bioController,
                                          label: 'About you...',
                                          // prefixIcon:
                                          //     const Icon(Icons.person_rounded),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        CustomTextField(
                                          fieldValidator: _formFieldsValidator,
                                          textEditingController:
                                              _fnameController,
                                          keyboardType: TextInputType.name,
                                          label: 'Enter your first name',
                                          prefixIcon:
                                              const Icon(Icons.person_rounded),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        CustomTextField(
                                            fieldValidator:
                                                _formFieldsValidator,
                                            textEditingController:
                                                _lnameController,
                                            keyboardType: TextInputType.name,
                                            label: 'Enter your last name',
                                            prefixIcon: const Icon(
                                                Icons.person_rounded)),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        CustomTextField(
                                            fieldValidator:
                                                _formFieldsValidator,
                                            textEditingController:
                                                _usernameController,
                                            label: 'Enter your username',
                                            prefixIcon: const Icon(
                                                Icons.person_rounded)),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        CustomTextField(
                                            fieldValidator:
                                                _emailFieldValidator,
                                            textEditingController:
                                                _emailController,
                                            label: 'Enter your email',
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            prefixIcon: const Icon(
                                                Icons.email_rounded)),
                                        // Column(
                                        //   crossAxisAlignment:
                                        //       CrossAxisAlignment.start,
                                        //   children: [
                                        //     TextField(
                                        //       readOnly: true,
                                        //       onTap: () => authData.updateUserEmail(
                                        //           _emailController.text, context),
                                        //       keyboardType:
                                        //           TextInputType.emailAddress,
                                        //       controller: _emailController,
                                        //       decoration:
                                        //           const InputDecoration.collapsed(
                                        //               hintText: "Enter your email"),
                                        //     ),
                                        //   ],
                                        // ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Flexible(
                                                        fit: FlexFit.loose,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Flexible(
                                                        fit: FlexFit.loose,
                                                        child: TextButton(
                                                            onPressed: () {
                                                              showDialog<
                                                                      Widget>(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          builder) {
                                                                    return AlertDialog(
                                                                        actions: [
                                                                          TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: const Text("No")),
                                                                          TextButton(
                                                                              onPressed: () => authData.deleteAccount(context).then((value) => Navigator.pushNamed(context, '/')),
                                                                              child: const Text("Yes"))
                                                                        ],
                                                                        content:
                                                                            const Text('Are you sure you want to delete the account?'));
                                                                  });
                                                            },
                                                            child: Text(
                                                              'Delete Account',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red
                                                                      .shade600),
                                                            )))
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ])));
                        }))));
  }

  _getUserData() async {
    final uid = Provider.of<AuthenticationService>(context).getCurrentUID();
    try {
      await Provider.of<FirebaseFirestore>(context)
          .collection('users')
          .doc(uid)
          .get()
          .then((value) {
        user.firstName = value.data()!['first_name'];
        user.lastName = value.data()!['last_name'];
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
