import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: "Password",
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.createUserWithEmailAndPassword(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text("Register"),
          )
        ],
      ),
    );
  }
}
