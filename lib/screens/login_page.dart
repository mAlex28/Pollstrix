import 'package:flutter/material.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Color _textColor(BuildContext context) {
    if (NeumorphicTheme.isUsingDark(context)) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);
    return Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Neumorphic(
                    margin: const EdgeInsets.only(
                        left: 8, right: 8, top: 2, bottom: 4),
                    style: NeumorphicStyle(
                      depth: NeumorphicTheme.embossDepth(context),
                      boxShape: const NeumorphicBoxShape.stadium(),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 18),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Enter your email"),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Neumorphic(
                    margin: const EdgeInsets.only(
                        left: 8, right: 8, top: 2, bottom: 4),
                    style: NeumorphicStyle(
                      depth: NeumorphicTheme.embossDepth(context),
                      boxShape: const NeumorphicBoxShape.stadium(),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 18),
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Enter your password"),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeumorphicButton(
                      margin: const EdgeInsets.only(
                          left: 8, right: 8, top: 2, bottom: 4),
                      onPressed: () {
                        authService.signInWithEmailAndPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
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
                        "Login",
                        style: TextStyle(color: _textColor(context)),
                      )),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              //  ElevatedButton(
              //   onPressed: () {
              //     Navigator.pushNamed(context, '/register');
              //   },
              //   child: const Text("New Account"),
              // )
            ],
          ),
        ));
  }
}

// Positioned(
//     top: 0,
//     left: 0,
//     child: Image.asset(
//       "assets/images/signup_top.png",
//       width: size.width * 0.35,
//     ),
//   ),