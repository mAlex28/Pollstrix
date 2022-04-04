import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/custom/custom_snackbar.dart';
import 'package:pollstrix/custom/custom_textfield.dart';
import 'package:pollstrix/custom/image_selection.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:pollstrix/services/theme_service.dart';
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
  bool _isPasswordVisible = false;
  bool _isRegistered = false;

  // ignore: prefer_typing_uninitialized_variables
  var deviceId;

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

  Future<void> getDeviceIdentifier() async {
    String deviceIdentifier = "unknown";
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
      // create a unique identifier for web
      deviceIdentifier = webBrowserInfo.vendor! +
          webBrowserInfo.userAgent! +
          webBrowserInfo.hardwareConcurrency.toString();
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;
        deviceIdentifier = androidDeviceInfo.androidId!;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        deviceIdentifier = iosDeviceInfo.identifierForVendor!;
      }
    }
    setState(() {
      deviceId = deviceIdentifier;
    });
  }

  _checkIfDeviceIsRegistered() async {
    await FirebaseFirestore.instance
        .collection('deviceIDs')
        .get()
        .then((value) {
      value.docs.map((e) {
        setState(() {
          if (e.id == deviceId) {
            _isRegistered = true;
          }
        });
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getDeviceIdentifier();
    _checkIfDeviceIsRegistered();
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
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
        body: _isLoading
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text('Registering user...')
                ],
              ))
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
                              SizedBox(width: kSpacingUnit.h * 3),
                              SizedBox(width: kSpacingUnit.h * 3),
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
                                  textEditingController: _usernameController,
                                  label: 'Enter your username',
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
                                  password: _isPasswordVisible,
                                  suffixIcon: IconButton(
                                      iconSize: 18.0,
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                      icon: Icon(_isPasswordVisible
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded)),
                                  textEditingController: _passwordController,
                                  label: 'Enter your password',
                                  prefixIcon:
                                      const Icon(Icons.password_rounded)),
                              const SizedBox(
                                height: 20,
                              ),
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
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  if (_formKey.currentState != null &&
                                      _formKey.currentState!.validate()) {
                                    if (_isRegistered) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          CustomWidgets.customSnackbar(
                                              backgroundColor: Colors.red,
                                              content:
                                                  'Device is already registered'));
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    } else {
                                      await authService
                                          .createUserWithEmailAndPassword(
                                              fname:
                                                  _fnameController.text.trim(),
                                              lname:
                                                  _lnameController.text.trim(),
                                              username: _usernameController.text
                                                  .trim(),
                                              email:
                                                  _emailController.text.trim(),
                                              password: _passwordController.text
                                                  .trim(),
                                              imageUrl: imageUrl,
                                              deviceId: deviceId,
                                              context: context);

                                      Navigator.pushNamed(context, '/');

                                      setState(() {
                                        _isLoading = false;
                                      });
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
                                      onPressed: () => Navigator.pushNamed(
                                          context, '/login'),
                                      child: const Text(
                                        'Have an account? Login',
                                      )),
                                ],
                              ),
                            ],
                          ),
                        )))));
  }
}
