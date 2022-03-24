import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
    final size = MediaQuery.of(context).size;
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
                      padding: const EdgeInsets.all(35),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              "assets/images/logo.png",
                              width: size.width * 0.2,
                              fit: BoxFit.contain,
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
                                final signInFunction =
                                    authService.signInWithEmailAndPassword(
                                        email: _emailController.text.trim(),
                                        password:
                                            _passwordController.text.trim(),
                                        context: context);

                                _waitAndCheckErrors(() => signInFunction);
                              },
                              child: const Text(
                                "Sign In",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
  }

  // Widget _webView() {
  //   final size = MediaQuery.of(context).size;
  //   return Container(
  //       alignment: Alignment.center,
  //       child: SingleChildScrollView(
  //         child: Container(
  //           padding: EdgeInsets.only(
  //               left: size.width * 0.3, right: size.width * 0.3),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: <Widget>[
  //               Image.asset(
  //                 "assets/images/logo.png",
  //                 // width: size.width * 0.28,
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               const Text(
  //                 'Pollstrix',
  //                 style: TextStyle(
  //                     fontSize: 25,
  //                     fontStyle: FontStyle.italic,
  //                     fontWeight: FontWeight.w600),
  //               ),
  //               const SizedBox(
  //                 height: 30,
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   CustomTextField(
  //                     fieldValidator: (value) {
  //                       String pattern =
  //                           r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  //                       RegExp regExp = RegExp(pattern);

  //                       if (value == null || value.trim().isEmpty) {
  //                         return 'This field is required';
  //                       } else if (!regExp.hasMatch(value.trim())) {
  //                         return 'Invalid email address';
  //                       }
  //                     },
  //                     textEditingController: _emailController,
  //                     label: 'Enter your email',
  //                     prefixIcon: const Icon(Icons.person_rounded),
  //                     keyboardType: TextInputType.emailAddress,
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(
  //                 height: 20,
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   CustomTextField(
  //                     fieldValidator: (value) {
  //                       if (value == null || value.trim().isEmpty) {
  //                         return "This field is requied";
  //                       }
  //                     },
  //                     textEditingController: _passwordController,
  //                     label: 'Enter your password',
  //                     prefixIcon: const Icon(Icons.password_rounded),
  //                     keyboardType: TextInputType.visiblePassword,
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(
  //                 height: 25,
  //               ),
  //               ElevatedButton(
  //                 style: ButtonStyle(
  //                   backgroundColor:
  //                       MaterialStateProperty.all(Colors.blueAccent),
  //                   shape: MaterialStateProperty.all(RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(50))),
  //                   elevation: MaterialStateProperty.all(8),
  //                   padding: MaterialStateProperty.all(
  //                       const EdgeInsets.symmetric(
  //                           vertical: 12, horizontal: 40)),
  //                 ),
  //                 onPressed: () async {
  //                   // await authService.signInWithEmailAndPassword(
  //                   //     email: _emailController.text.trim(),
  //                   //     password: _passwordController.text.trim(),
  //                   //     context: context);
  //                 },
  //                 child: const Text(
  //                   "Sign In",
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 15,
  //               ),
  //               Column(
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Column(
  //                         children: [
  //                           TextButton(
  //                               onPressed: () => Navigator.pushNamed(
  //                                   context, '/forgot-password'),
  //                               child: const Text(
  //                                 'Forgot password',
  //                               ))
  //                         ],
  //                       ),
  //                       Column(
  //                         children: [
  //                           TextButton(
  //                               onPressed: () =>
  //                                   Navigator.pushNamed(context, '/register'),
  //                               child: const Text(
  //                                 'Create a new account',
  //                               ))
  //                         ],
  //                       ),
  //                     ],
  //                   )
  //                 ],
  //               ),
  //               const SizedBox(
  //                 height: 15,
  //               ),
  //               Container(
  //                 margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
  //                 width: size.width * 0.8,
  //                 child: Row(
  //                   children: <Widget>[
  //                     buildDivider(),
  //                     const Padding(
  //                       padding: EdgeInsets.symmetric(horizontal: 10),
  //                       child: Text(
  //                         "OR",
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                       ),
  //                     ),
  //                     buildDivider(),
  //                   ],
  //                 ),
  //               ),
  //               const GoogleSignInButton(),
  //             ],
  //           ),
  //         ),
  //       ));
  // }

  Expanded buildDivider() {
    return const Expanded(
      child: Divider(
        color: Color(0xFFD9D9D9),
        height: 1.5,
      ),
    );
  }
}
