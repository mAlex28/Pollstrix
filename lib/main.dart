import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pollstrix/screens/home_page.dart';
import 'package:pollstrix/screens/login_page.dart';
import 'package:pollstrix/screens/register_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:pollstrix/models/user_model.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  get initialData => null;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(create: (_) => AuthenticationService()),
      ],
      child: NeumorphicApp(
        title: 'Pollstrix',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: const NeumorphicThemeData(
          baseColor: Color(0xFFFFFFFF),
          lightSource: LightSource.topLeft,
          depth: 10,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthenticationWrapper(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage()
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);
    return StreamBuilder<User?>(
        stream: authService.user,
        builder: (_, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final User? user = snapshot.data;

            return user == null ? const LoginPage() : const HomePage();
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
