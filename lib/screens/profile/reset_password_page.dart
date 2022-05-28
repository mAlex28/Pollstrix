import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/utilities/custom/custom_textfield.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/dialogs/password_reset_dialog.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

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
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: const Text('Reset Password'),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: kIsWeb
                    ? buildForWeb()
                    : Padding(
                        padding: const EdgeInsets.all(30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
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
                                label: 'Enter your email here',
                                prefixIcon: const Icon(Icons.email_rounded),
                                keyboardType: TextInputType.emailAddress,
                              ),
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
                                  elevation: MaterialStateProperty.all(8),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 40)),
                                ),
                                onPressed: () async {
                                  try {
                                    // send password reset link to the user
                                    await AuthService.firebase().resetPassword(
                                        email: _emailController.text.trim());

                                    await showChangePasswordDialog(context,
                                        'Check your inbox and follow the link to update the password');
                                  } catch (_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        CustomSnackbar.customSnackbar(
                                            backgroundColor: Colors.red,
                                            content:
                                                'Too many request! Try agian later'));
                                  }
                                },
                                child: Text(
                                  "Send Email",
                                  textAlign: TextAlign.center,
                                  style: kButtonTextStyle,
                                ),
                              ),
                            ],
                          ),
                        )))));
  }

  Widget buildForWeb() {
    return SizedBox(
      width: 400,
      child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
                  label: 'Enter your email here',
                  prefixIcon: const Icon(Icons.email_rounded),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: kLightPrimaryColor,
                    )),
                    backgroundColor: MaterialStateProperty.all(kAccentColor),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                    elevation: MaterialStateProperty.all(8),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 40)),
                  ),
                  onPressed: () async {
                    try {
                      await AuthService.firebase()
                          .resetPassword(email: _emailController.text.trim());

                      await showChangePasswordDialog(context,
                          'Check your inbox and follow the link to verify the password');
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackbar.customSnackbar(
                              backgroundColor: Colors.red,
                              content: 'Too many request! Try agian later'));
                    }
                  },
                  child: const Text(
                    "Send Email",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
