import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';
import 'package:pollstrix/utilities/custom/custom_textfield.dart';
import 'package:pollstrix/utilities/custom/buttons/google_signin_button.dart';
import 'package:pollstrix/utilities/custom/terms_of_user.dart';
import 'package:pollstrix/services/auth/auth_exceptions.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/theme_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isLoading = false;
  bool _isPassword = true;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
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

    return Scaffold(
        body: _isLoading
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: kAccentColor,
                  ),
                  Text('Logging user. Please wait...')
                ],
              ))
            : kIsWeb
                ? buildForWeb()
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

                                  return null;
                                },
                                textEditingController: _emailController,
                                label: 'Email',
                                prefixIcon: const Icon(Icons.person_rounded),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              CustomTextField(
                                fieldValidator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                password: _isPassword,
                                textEditingController: _passwordController,
                                label: 'Password',
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
                                  textStyle: MaterialStateProperty.all(
                                      kButtonTextStyle),
                                  backgroundColor:
                                      MaterialStateProperty.all(kAccentColor),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50))),
                                  elevation: MaterialStateProperty.all(8),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 40)),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();

                                    try {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await AuthService.firebase().logIn(
                                          email: email, password: password);
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      final user =
                                          AuthService.firebase().currentUser;

                                      if (user?.isEmailVerified ?? false) {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          homeRoute,
                                          (route) => false,
                                        );
                                      } else {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          verifyEmailRoute,
                                          (route) => false,
                                        );
                                      }
                                    } on UserNotFoundAuthException {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              CustomSnackbar.customSnackbar(
                                                  backgroundColor: Colors.red,
                                                  content: 'User not found'));
                                    } on WrongPasswordAuthException {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              CustomSnackbar.customSnackbar(
                                                  backgroundColor: Colors.red,
                                                  content: 'Wrong password'));
                                    } on GenericAuthException {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          CustomSnackbar.customSnackbar(
                                              backgroundColor: Colors.red,
                                              content:
                                                  'Oops! something went wrong'));
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                          fit: FlexFit.loose,
                                          child: TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pushNamedAndRemoveUntil(
                                                          registerRoute,
                                                          (route) => false),
                                              child: const Text(
                                                'Create a new account',
                                              )))
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                          fit: FlexFit.loose,
                                          child: TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pushNamedAndRemoveUntil(
                                                          forgotPasswordRoute,
                                                          (route) => false),
                                              child: const Text(
                                                'Forgot password',
                                              )))
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: size.height * 0.02),
                                width: size.width * 0.8,
                                child: Row(
                                  children: <Widget>[
                                    buildDivider(),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                              SizedBox(height: kSpacingUnit.h * 2),
                              const TermsOfUse(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
  }

// for website
  Widget buildForWeb() {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.only(top: 35),
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

                      return null;
                    },
                    textEditingController: _emailController,
                    label: 'Email',
                    prefixIcon: const Icon(Icons.person_rounded),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextField(
                    fieldValidator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "This field is required";
                      }
                      return null;
                    },
                    password: _isPassword,
                    textEditingController: _passwordController,
                    label: 'Password',
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
                      textStyle: MaterialStateProperty.all(const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: kLightPrimaryColor,
                      )),
                      backgroundColor: MaterialStateProperty.all(kAccentColor),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                      elevation: MaterialStateProperty.all(8),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 40)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        try {
                          await AuthService.firebase()
                              .logIn(email: email, password: password);

                          final user = AuthService.firebase().currentUser;

                          if (user?.isEmailVerified ?? false) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              homeRoute,
                              (route) => false,
                            );
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              verifyEmailRoute,
                              (route) => false,
                            );
                          }
                        } on UserNotFoundAuthException {
                          ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackbar.customSnackbar(
                                  backgroundColor: Colors.red,
                                  content: 'User not found'));
                        } on WrongPasswordAuthException {
                          ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackbar.customSnackbar(
                                  backgroundColor: Colors.red,
                                  content: 'Wrong password'));
                        } on GenericAuthException {
                          ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackbar.customSnackbar(
                                  backgroundColor: Colors.red,
                                  content: 'Oops! something went wrong'));
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              fit: FlexFit.loose,
                              child: TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                          registerRoute, (route) => false),
                                  child: const Text(
                                    'Create a new account',
                                  )))
                        ],
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              fit: FlexFit.loose,
                              child: TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                          forgotPasswordRoute,
                                          (route) => false),
                                  child: const Text(
                                    'Forgot password',
                                  )))
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: kSpacingUnit.h * 2),
                  const TermsOfUse(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
