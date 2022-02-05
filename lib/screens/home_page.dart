import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late User _user;
  // bool _isSigningOut = false;

  // @override
  // void initState() {
  //   // _user = widget._user;

  //   super.initState();
  // }

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


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text("HOME"),
//             ElevatedButton(
//               onPressed: () async {
//                 await context.read<AuthenticationService>().signOut();
//               },
//               child: const Text("Sign out"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
