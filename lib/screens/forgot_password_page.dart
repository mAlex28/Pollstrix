import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_textfield.dart';
import 'package:pollstrix/services/auth_service.dart';
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
    final size = MediaQuery.of(context).size;
    final authService = Provider.of<AuthenticationService>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: SingleChildScrollView(
                child: Container(
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            verticalDirection: VerticalDirection.down,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/logo.png",
                                width: size.width * 0.28,
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
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.blueAccent),
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
                                  await authService.resetPassword(
                                      email: _emailController.text.trim(),
                                      context: context);
                                },
                                child: const Text(
                                  "Send Email",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
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
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                              fit: FlexFit.loose,
                                              child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pushNamed(
                                                          context, '/login'),
                                                  child: const Text(
                                                    'Have an account',
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
                            ],
                          ),
                        ))))));
  }
}
