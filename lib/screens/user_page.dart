import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/custom/custom_textfield.dart';
import 'package:pollstrix/custom/image_selection.dart';
import 'package:pollstrix/models/user_model.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:pollstrix/services/theme_service.dart';
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

  @override
  void didChangeDependencies() {
    _getUserProfile();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(360, 690),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);

    final authData = Provider.of<AuthenticationService>(context);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Platform.isIOS
                ? const Icon(Icons.arrow_back_ios)
                : const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'User Profile',
            style: kTitleTextStyle.copyWith(fontWeight: FontWeight.w700),
          ),
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
                icon: const Icon(
                  Icons.done_rounded,
                  color: kAccentColor,
                ))
          ],
        ),
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
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
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
                                        TextField(
                                          readOnly: true,
                                          autofocus: false,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                              suffix: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          actions: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: const Text(
                                                                        "Cancel")),
                                                                TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await authData.updateUserEmail(
                                                                          _emailController
                                                                              .text,
                                                                          context);
                                                                    },
                                                                    child: const Text(
                                                                        "Confirm"))
                                                              ],
                                                            )
                                                          ],
                                                          title: Text(
                                                              'Change your email..',
                                                              style:
                                                                  kTitleTextStyle
                                                                      .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              )),
                                                          content: TextField(
                                                            onChanged:
                                                                (value) {},
                                                            controller:
                                                                _emailController,
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        "Email here..."),
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: const Text(
                                                  'Change email',
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: kAccentColor),
                                                ),
                                              ),
                                              prefixIcon: const Icon(
                                                  Icons.email_rounded),
                                              hintText: "Enter your email",
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 15, 20, 15),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20))),
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
