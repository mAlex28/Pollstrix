import 'package:flutter/material.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

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
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
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
                          hintText: "Enter your email address here"),
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
                        authService.resetPassword(
                            email: _emailController.text.trim(),
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
                        "Send Email",
                        style: TextStyle(color: _textColor(context)),
                      )),
                ],
              ),
            ],
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
