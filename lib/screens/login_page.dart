import 'package:flutter/material.dart';
import 'package:pollstrix/custom/google_signin_button.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
    final size = MediaQuery.of(context).size;
    final authService = Provider.of<AuthenticationService>(context);
    return Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: kIsWeb
            ? _webView()
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                      context: context);
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
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 18),
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
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 18),
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
                                padding: EdgeInsets.symmetric(horizontal: 10),
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
                        // const SizedBox(
                        //   height: 50,
                        // ),
                        // const Text(
                        //   'developed by alex',
                        //   style: TextStyle(fontSize: 12),
                        // )
                      ],
                    ),
                  ),
                )));
  }

  Widget _webView() {
    final size = MediaQuery.of(context).size;
    return Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                left: size.width * 0.3, right: size.width * 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/logo.png",
                  // width: size.width * 0.28,
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
                  height: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeumorphicButton(
                        margin: const EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 4),
                        onPressed: () {},
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
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/forgot-password'),
                                child: const Text(
                                  'Forgot password',
                                ))
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/register'),
                                child: const Text(
                                  'Create a new account',
                                ))
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
                  margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  width: size.width * 0.8,
                  child: Row(
                    children: <Widget>[
                      buildDivider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
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
        ));
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
