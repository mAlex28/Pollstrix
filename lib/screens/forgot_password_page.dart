import 'package:flutter/material.dart';
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/utilities/custom/custom_textfield.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/dialogs/password_reset_dialog.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          SizedBox(
                            height: kToolbarHeight * 0.7,
                            child: Image.asset(
                              "assets/images/logo_inapp.png",
                              color: kAccentColor,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
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
                                      borderRadius: BorderRadius.circular(50))),
                              elevation: MaterialStateProperty.all(8),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 40)),
                            ),
                            onPressed: () async {
                              try {
                                await AuthService.firebase().forgotPassword(
                                    email: _emailController.text.trim());

                                await showChangePasswordDialog(context,
                                    'Check your inbox and follow the link to verify the password');
                              } on Exception catch (_) {
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
                                                  Navigator.of(context)
                                                      .pushNamedAndRemoveUntil(
                                                          loginRoute,
                                                          (route) => false),
                                              child: const Text(
                                                'Have an account?',
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
                              )
                            ],
                          ),
                        ],
                      ),
                    )))));
  }
}
