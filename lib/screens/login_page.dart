import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';
import 'package:pollstrix/custom/custom_textfield.dart';
import 'package:pollstrix/custom/google_signin_button.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPassword = true;

  Future<void> _waitAndCheckErrors(
    Future<void> Function() signInFunction,
  ) async {
    setState(() => _isLoading = true);
    try {
      await signInFunction();
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red, content: e.toString()));
      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(CustomWidgets.customSnackbar(
          backgroundColor: Colors.red,
          content: 'Error signing in to the account.'));
      setState(() => _isLoading = false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

    final size = MediaQuery.of(context).size;
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(35),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: kSpacingUnit.w * 3),
                          SizedBox(
                            height: kToolbarHeight * 0.7,
                            child: Image.asset(
                              "assets/images/logo_inapp.png",
                              color: kAccentColor,
                            ),
                          ),
                          const SizedBox(
                            height: 45,
                          ),
                          CustomTextField(
                            fieldValidator: (value) {
                              String pattern =
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                              RegExp regExp = RegExp(pattern);

                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              } else if (!regExp.hasMatch(value.trim())) {
                                return 'Invalid email address';
                              }
                            },
                            textEditingController: _emailController,
                            label: 'Enter your email',
                            prefixIcon: const Icon(Icons.person_rounded),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            fieldValidator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "This field is requied";
                              }
                            },
                            password: _isPassword,
                            textEditingController: _passwordController,
                            label: 'Enter your password',
                            prefixIcon: const Icon(Icons.password_rounded),
                            suffixIcon: IconButton(
                                iconSize: 18.0,
                                onPressed: () {
                                  setState(() {
                                    _isPassword = !_isPassword;
                                  });
                                },
                                icon: Icon(_isPassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded)),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              textStyle:
                                  MaterialStateProperty.all(kButtonTextStyle),
                              backgroundColor:
                                  MaterialStateProperty.all(kAccentColor),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              elevation: MaterialStateProperty.all(8),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 40)),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                try {
                                  await authService.signInWithEmailAndPassword(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                      context: context);
                                  // Navigator.push(context, '/');
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      CustomWidgets.customSnackbar(
                                          backgroundColor: Colors.red,
                                          content: e.message.toString()));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      CustomWidgets.customSnackbar(
                                          backgroundColor: Colors.red,
                                          content:
                                              'Error loging in. Try again'));
                                }
                              }
                            },
                            child: const Text(
                              "Sign In",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                          fit: FlexFit.loose,
                                          child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pushNamed(context,
                                                      '/forgot-password'),
                                              child: const Text(
                                                'Forgot password',
                                              )))
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                          fit: FlexFit.loose,
                                          child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pushNamed(
                                                      context, '/register'),
                                              child: const Text(
                                                'Create a new account',
                                              )))
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: size.height * 0.02),
                            width: size.width * 0.8,
                            child: Row(
                              children: <Widget>[
                                buildDivider(),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                buildDivider(),
                              ],
                            ),
                          ),
                          const GoogleSignInButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  Expanded buildDivider() {
    return const Expanded(
      child: Divider(
        color: Color(0xFFD9D9D9),
        height: 1.5,
      ),
    );
  }
}
