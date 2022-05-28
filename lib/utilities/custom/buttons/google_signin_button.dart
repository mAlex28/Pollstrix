import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/services/auth/auth_exceptions.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).backgroundColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        onPressed: () async {
          try {
            setState(() {
              _isSigningIn = true;
            });
            await AuthService.firebase().signInWithGoogle();
            setState(() {
              _isSigningIn = false;
            });
            Navigator.of(context).pushNamedAndRemoveUntil(
              homeRoute,
              (route) => false,
            );
          } on AccountExistsWithDifferentCredentialsException {
            ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackbar.customSnackbar(
                    backgroundColor: Colors.red,
                    content:
                        'This account already exists with a different credential.'));
          } on InvalidCredentialsException {
            ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackbar.customSnackbar(
                    backgroundColor: Colors.red,
                    content:
                        'Error occurred while accessing credentials. Try again.'));
          } on GenericAuthException {
            ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackbar.customSnackbar(
                    backgroundColor: Colors.red,
                    content: 'Oops! something went wrong'));
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Image(
                image: AssetImage("assets/images/google_logo.png"),
                height: kIsWeb ? 20 : 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _isSigningIn
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
                      )
                    : Text('Sign in with Google',
                        style: TextStyle(color: Colors.grey.shade600)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
