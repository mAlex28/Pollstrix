import 'package:flutter/material.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("HOME"),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthenticationService>().signOut();
              },
              child: const Text("Sign out"),
            ),
          ],
        ),
      ),
    );
  }
}
