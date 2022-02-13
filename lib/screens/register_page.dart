import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: SafeArea(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Center(
                    child: SingleChildScrollView(
                        child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
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
                          label: 'Enter your first name'),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                          fieldValidator: _formFieldsValidator,
                          textEditingController: _lnameController,
                          label: 'Enter your last name'),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                          fieldValidator: _formFieldsValidator,
                          textEditingController: _usernameController,
                          label: 'Enter your username'),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                          fieldValidator: _emailFieldValidator,
                          textEditingController: _emailController,
                          label: 'Enter your email'),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                          fieldValidator: _passwordFieldValidator,
                          password: true,
                          textEditingController: _passwordController,
                          label: 'Enter your password'),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeumorphicButton(
                              margin: const EdgeInsets.only(
                                  left: 8, right: 8, top: 2, bottom: 4),
                              onPressed: () {
                                if (_formKey.currentState != null &&
                                    _formKey.currentState!.validate()) {
                                  setState(() {});

                                  authService.createUserWithEmailAndPassword(
                                      fname: _fnameController.text.trim(),
                                      lname: _lnameController.text.trim(),
                                      username: _usernameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                      imageUrl: imageUrl,
                                      context: context);

                                  // Navigator.pushNamed(context, '/');
                                }
                              },
                              style: NeumorphicStyle(
                                color: Colors.blueAccent,
                                shape: NeumorphicShape.flat,
                                depth: NeumorphicTheme.embossDepth(context),
                                boxShape: const NeumorphicBoxShape.stadium(),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 50),
                              child: Text(
                                "Create Account",
                                style: TextStyle(color: _textColor(context)),
                              )),
                        ],
                      ),
                    ],
                  ),
                ))))));
  }
}
