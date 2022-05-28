import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/services/auth/auth_exceptions.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/cloud/other/firebase_other_functions.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';
import 'package:pollstrix/utilities/custom/custom_textfield.dart';
import 'package:pollstrix/utilities/custom/image_selection.dart';
import 'package:pollstrix/services/theme_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _fnameController;
  late final TextEditingController _lnameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FirebaseOtherFunctions _deviceService;
  final _formKey = GlobalKey<FormState>();
  String imageUrl = '';
  bool _isPassword = true;
  bool _isLoading = false;

  // common field validator
  String? _formFieldsValidator(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // email field validator
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

  // password field validator
  String? _passwordFieldValidator(String? text) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);

    if (text == null || text.trim().isEmpty) {
      return 'This field is required';
    } else if (!regExp.hasMatch(text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar.customSnackbar(
          backgroundColor: Colors.red,
          content:
              'Password should be 8 characters with mix of at least 1 uppercase, 1 lower case, 1 digit and 1 special character'));
      return 'Invalid password';
    }

    return null;
  }

  /// Get the unique device IDs on each platform (Web, Ios and Android)
  Future<String> _getDeviceIdentifier() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
      // create a unique identifier for web
      return webBrowserInfo.vendor! +
          webBrowserInfo.userAgent! +
          webBrowserInfo.hardwareConcurrency.toString();
    } else {
      // get android id
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;
        return androidDeviceInfo.androidId!;
      } else {
        // get apple identifier for vendor
        IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        return iosDeviceInfo.identifierForVendor!;
      }
    }
  }

  @override
  void initState() {
    _fnameController = TextEditingController();
    _lnameController = TextEditingController();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _deviceService = FirebaseOtherFunctions();
    super.initState();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _displayNameController.dispose();
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
                Text('Registering user. Please wait...')
              ],
            ))
          : kIsWeb
              ? buildForWeb()
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: kToolbarHeight * 0.7,
                              child: Image.asset(
                                "assets/images/logo_inapp.png",
                                color: kAccentColor,
                              ),
                            ),
                            SizedBox(height: kSpacingUnit.h * 3),
                            UserImage(
                              onFileChanged: (imageUrl) {
                                setState(() {
                                  this.imageUrl = imageUrl;
                                });
                              },
                              isProfile: false,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            CustomTextField(
                              fieldValidator: _formFieldsValidator,
                              textEditingController: _fnameController,
                              keyboardType: TextInputType.name,
                              label: 'Enter your first name',
                              prefixIcon: const Icon(Icons.person_rounded),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            CustomTextField(
                                fieldValidator: _formFieldsValidator,
                                textEditingController: _lnameController,
                                keyboardType: TextInputType.name,
                                label: 'Enter your last name',
                                prefixIcon: const Icon(Icons.person_rounded)),
                            const SizedBox(
                              height: 20,
                            ),
                            CustomTextField(
                                fieldValidator: _formFieldsValidator,
                                textEditingController: _displayNameController,
                                label: 'Enter your displayname',
                                prefixIcon: const Icon(Icons.person_rounded)),
                            const SizedBox(
                              height: 20,
                            ),
                            CustomTextField(
                                fieldValidator: _emailFieldValidator,
                                textEditingController: _emailController,
                                label: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.email_rounded)),
                            const SizedBox(
                              height: 20,
                            ),
                            CustomTextField(
                                fieldValidator: _passwordFieldValidator,
                                password: _isPassword,
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
                                textEditingController: _passwordController,
                                label: 'Enter your password',
                                prefixIcon: const Icon(Icons.password_rounded)),
                            SizedBox(height: kSpacingUnit.h * 3),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(kAccentColor),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                                elevation: MaterialStateProperty.all(5),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 40)),
                              ),
                              onPressed: () async {
                                final deviceId = await _getDeviceIdentifier();

                                final isDeviceRegistered = await _deviceService
                                    .checkIfTheCurrentDeviceIsRegistered(
                                        deviceId: deviceId);

                                // check if the device registered and register is it hasn't
                                if (isDeviceRegistered) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      CustomSnackbar.customSnackbar(
                                          content:
                                              'Your device is already registered',
                                          backgroundColor: Colors.red));
                                } else {
                                  if (_formKey.currentState != null &&
                                      _formKey.currentState!.validate()) {
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    final firstName =
                                        _fnameController.text.trim();
                                    final lastName =
                                        _lnameController.text.trim();
                                    final displayName =
                                        _displayNameController.text.trim();

                                    try {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      // create a new user
                                      await AuthService.firebase().createUser(
                                          email: email,
                                          password: password,
                                          displayName: displayName,
                                          firstName: firstName,
                                          lastName: lastName,
                                          imageUrl: imageUrl);

                                      // add device ID to the firebase
                                      await _deviceService.saveDeviceId(
                                          deviceId: deviceId,
                                          userId: 'unknown user');

                                      // send email veification to the user
                                      await AuthService.firebase()
                                          .sendEmailVerification();
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      Navigator.of(context)
                                          .pushNamed(verifyEmailRoute);
                                    } on WeakPasswordAuthException {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              CustomSnackbar.customSnackbar(
                                                  backgroundColor: Colors.red,
                                                  content: 'Weak password'));
                                    } on EmailAlreadyInUseAuthException {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              CustomSnackbar.customSnackbar(
                                                  backgroundColor: Colors.red,
                                                  content:
                                                      'Email already in use'));
                                    } on InvalidEmailAuthException {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              CustomSnackbar.customSnackbar(
                                                  backgroundColor: Colors.red,
                                                  content:
                                                      'Invalid email address'));
                                    } on GenericAuthException {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          CustomSnackbar.customSnackbar(
                                              backgroundColor: Colors.red,
                                              content:
                                                  'Oops! Something went wrong'));
                                    }
                                  }
                                }
                              },
                              child: Text(
                                "Create Account",
                                textAlign: TextAlign.center,
                                style: kButtonTextStyle,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            loginRoute, (route) => false),
                                    child: const Text(
                                      'Have an account? Login',
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget buildForWeb() {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: kToolbarHeight * 0.7,
                    child: Image.asset(
                      "assets/images/logo_inapp.png",
                      color: kAccentColor,
                    ),
                  ),
                  SizedBox(height: kSpacingUnit.h * 3),
                  UserImage(
                    onFileChanged: (imageUrl) {
                      setState(() {
                        this.imageUrl = imageUrl;
                      });
                    },
                    isProfile: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomTextField(
                    fieldValidator: _formFieldsValidator,
                    textEditingController: _fnameController,
                    keyboardType: TextInputType.name,
                    label: 'Enter your first name',
                    prefixIcon: const Icon(Icons.person_rounded),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      fieldValidator: _formFieldsValidator,
                      textEditingController: _lnameController,
                      keyboardType: TextInputType.name,
                      label: 'Enter your last name',
                      prefixIcon: const Icon(Icons.person_rounded)),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      fieldValidator: _formFieldsValidator,
                      textEditingController: _displayNameController,
                      label: 'Enter your displayname',
                      prefixIcon: const Icon(Icons.person_rounded)),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      fieldValidator: _emailFieldValidator,
                      textEditingController: _emailController,
                      label: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_rounded)),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      fieldValidator: _passwordFieldValidator,
                      password: _isPassword,
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
                      textEditingController: _passwordController,
                      label: 'Enter your password',
                      prefixIcon: const Icon(Icons.password_rounded)),
                  SizedBox(height: kSpacingUnit.h * 3),
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
                      elevation: MaterialStateProperty.all(5),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 40)),
                    ),
                    onPressed: () async {
                      final deviceId = await _getDeviceIdentifier();

                      final isDeviceRegistered = await _deviceService
                          .checkIfTheCurrentDeviceIsRegistered(
                              deviceId: deviceId);

                      // check if the device registered and register is it hasn't
                      if (isDeviceRegistered) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackbar.customSnackbar(
                                content: 'Your device is already registered',
                                backgroundColor: Colors.red));
                      } else {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          final firstName = _fnameController.text.trim();
                          final lastName = _lnameController.text.trim();
                          final displayName =
                              _displayNameController.text.trim();

                          try {
                            setState(() {
                              _isLoading = true;
                            });
                            // create a new user
                            await AuthService.firebase().createUser(
                                email: email,
                                password: password,
                                displayName: displayName,
                                firstName: firstName,
                                lastName: lastName,
                                imageUrl: imageUrl);

                            // add device ID to the firebase
                            await _deviceService.saveDeviceId(
                                deviceId: deviceId, userId: 'unknown user');

                            // send email veification to the user
                            await AuthService.firebase()
                                .sendEmailVerification();
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pushNamed(verifyEmailRoute);
                          } on WeakPasswordAuthException {
                            ScaffoldMessenger.of(context).showSnackBar(
                                CustomSnackbar.customSnackbar(
                                    backgroundColor: Colors.red,
                                    content: 'Weak password'));
                          } on EmailAlreadyInUseAuthException {
                            ScaffoldMessenger.of(context).showSnackBar(
                                CustomSnackbar.customSnackbar(
                                    backgroundColor: Colors.red,
                                    content: 'Email already in use'));
                          } on InvalidEmailAuthException {
                            ScaffoldMessenger.of(context).showSnackBar(
                                CustomSnackbar.customSnackbar(
                                    backgroundColor: Colors.red,
                                    content: 'Invalid email address'));
                          } on GenericAuthException {
                            ScaffoldMessenger.of(context).showSnackBar(
                                CustomSnackbar.customSnackbar(
                                    backgroundColor: Colors.red,
                                    content: 'Oops! Something went wrong'));
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                                  loginRoute, (route) => false),
                          child: const Text(
                            'Have an account? Login',
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
