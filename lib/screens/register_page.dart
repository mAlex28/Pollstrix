import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';
import 'package:pollstrix/custom/custom_textfield.dart';
import 'package:pollstrix/custom/image_selection.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String imageUrl = '';
  bool _isLoading = false;

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  Future<void> _waitAndCheckErrors(
      Future<void> Function() signInFunction, context) async {
    setState(() => _isLoading = true);
    try {
      await signInFunction();
      Navigator.pushNamed(context, '/');
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(CustomWidgets.customSnackbar(content: e.toString()));
      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          content: 'Error signing in to the account.'));
      setState(() => _isLoading = false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                    child: Container(
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                          onPressed: () => Navigator.pushNamed(
                                              context, '/login'),
                                          child: const Text(
                                            'Have an account? Login',
                                          )),
                                    ],
                                  ),
                                  UserImage(
                                    onFileChanged: (imageUrl) {
                                      setState(() {
                                        this.imageUrl = imageUrl;
                                      });
                                    },
                                    isProfile: false,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    'Pollstrix',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  CustomTextField(
                                    fieldValidator: _formFieldsValidator,
                                    textEditingController: _fnameController,
                                    keyboardType: TextInputType.name,
                                    label: 'Enter your first name',
                                    prefixIcon:
                                        const Icon(Icons.person_rounded),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CustomTextField(
                                      fieldValidator: _formFieldsValidator,
                                      textEditingController: _lnameController,
                                      keyboardType: TextInputType.name,
                                      label: 'Enter your last name',
                                      prefixIcon:
                                          const Icon(Icons.person_rounded)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CustomTextField(
                                      fieldValidator: _formFieldsValidator,
                                      textEditingController:
                                          _usernameController,
                                      label: 'Enter your username',
                                      prefixIcon:
                                          const Icon(Icons.person_rounded)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CustomTextField(
                                      fieldValidator: _emailFieldValidator,
                                      textEditingController: _emailController,
                                      label: 'Enter your email',
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon:
                                          const Icon(Icons.email_rounded)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CustomTextField(
                                      fieldValidator: _passwordFieldValidator,
                                      password: true,
                                      textEditingController:
                                          _passwordController,
                                      label: 'Enter your password',
                                      prefixIcon:
                                          const Icon(Icons.password_rounded)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.blueAccent),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50))),
                                      elevation: MaterialStateProperty.all(5),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 40)),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState != null &&
                                          _formKey.currentState!.validate()) {
                                        final createAccount = authService
                                            .createUserWithEmailAndPassword(
                                                fname: _fnameController.text
                                                    .trim(),
                                                lname: _lnameController.text
                                                    .trim(),
                                                username: _usernameController
                                                    .text
                                                    .trim(),
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                                imageUrl: imageUrl,
                                                context: context);
                                        _waitAndCheckErrors(
                                            () => createAccount, context);
                                      }
                                    },
                                    child: const Text(
                                      "Create Account",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))))));
  }
}
