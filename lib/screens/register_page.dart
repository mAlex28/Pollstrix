import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
    final size = MediaQuery.of(context).size;
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        'Have an account? Login',
                      )),
                ],
              ),
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
                          hintText: "Enter your username"),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
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
                      controller: _emailController,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Enter your first name"),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
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
                      controller: _emailController,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Enter your last name"),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
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
                      controller: _emailController,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Enter your email"),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
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
                height: 20,
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
                        "Create Account",
                        style: TextStyle(color: _textColor(context)),
                      )),
                ],
              ),
            ],
          ),
        )));
  }
}
