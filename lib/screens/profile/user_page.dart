import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/users/firebase_user_functions.dart';
import 'package:pollstrix/utilities/custom/custom_textfield.dart';
import 'package:pollstrix/utilities/custom/image_selection.dart';
import 'package:pollstrix/models/user_model.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseUserFunctions _userFunctions = FirebaseUserFunctions();
  User user = User();
  bool isUpdating = false;
  String imageUrl = '';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  _getUserProfile() async {
    final profile = AuthService.firebase().currentUser!;

    if (profile.imageUrl != null) {
      setState(() {
        imageUrl = profile.imageUrl!;
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
                onPressed: () async {
                  setState(() {
                    isUpdating = true;
                  });
                  try {
                    await AuthService.firebase().updateUser(
                        documentId: AuthService.firebase().currentUser!.userId,
                        displayName: _usernameController.text,
                        firstName: _fnameController.text,
                        lastName: _lnameController.text,
                        imageUrl: imageUrl,
                        bio: _bioController.text);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        CustomSnackbar.customSnackbar(
                            backgroundColor: Colors.red,
                            content: 'Error updating account'));
                  }

                  setState(() {
                    isUpdating = false;
                    // });
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
                                            label: 'Enter your displayname',
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
                                                                Navigator.of(
                                                                        context)
                                                                    .pushNamed(
                                                                        resetPasswordRoute),
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
                                                                      title:
                                                                          const Text(
                                                                        'Please re-enter your password to delete the accont',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                      ),
                                                                      content: TextField(
                                                                          style: const TextStyle(fontSize: 12),
                                                                          decoration: InputDecoration(
                                                                              border: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(15.0),
                                                                                borderSide: BorderSide.none,
                                                                              ),
                                                                              filled: true,
                                                                              fillColor: Colors.grey[200],
                                                                              labelText: 'Password'),
                                                                          autocorrect: false,
                                                                          controller: _passwordController),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context),
                                                                            child: const Text("No")),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              if (_passwordController.text.isNotEmpty) {
                                                                                try {
                                                                                  final email = AuthService.firebase().currentUser!.email;
                                                                                  await AuthService.firebase().deleteUser(email: email, password: _passwordController.text.trim());
                                                                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                                                                    loginRoute,
                                                                                    (route) => false,
                                                                                  );
                                                                                } catch (e) {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar.customSnackbar(content: 'Error deleting account.', backgroundColor: Colors.red));
                                                                                  Navigator.pop(context);
                                                                                }
                                                                              } else {
                                                                                ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar.customSnackbar(content: 'Enter a valid password', backgroundColor: Colors.red));
                                                                                Navigator.pop(context);
                                                                              }
                                                                            },
                                                                            child:
                                                                                const Text("Yes"))
                                                                      ],
                                                                    );
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
    final uid = AuthService.firebase().currentUser!.userId;

    try {
      await _userFunctions.users.doc(uid).get().then((value) {
        user.firstName = value.data()![firstNameField];
        user.lastName = value.data()![lastNameField];
        user.email = value.data()![emailField];
        user.username = value.data()![displayNameField];
        user.bio = value.data()![bioField];
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
