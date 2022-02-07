import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pollstrix/screens/home_page.dart';
import 'package:pollstrix/screens/login_page.dart';
import 'package:pollstrix/screens/register_page.dart';
import 'package:pollstrix/screens/reset_password_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

// import 'package:pollstrix/models/user_model.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const firebaseConfig = FirebaseOptions(
    apiKey: 'AIzaSyBNEhcwHGg4XoSrWrPWg1LwZpYgfmoMPMo',
    appId: '1:630918106032:web:a36cc8f6d094035f4d2475',
    messagingSenderId: '630918106032',
    projectId: 'pollstrix-ec795',
    authDomain: 'pollstrix-ec795.firebaseapp.com',
    storageBucket: 'pollstrix-ec795.appspot.com',
    measurementId: 'G-Q0Z2QZ54QK',
  );

  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    await Firebase.initializeApp();
  }
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
          '/register': (context) => const RegisterPage(),
          '/reset-password': (context) => const ResetPasswordPage()
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
    return StreamBuilder<auth.User?>(
        stream: authService.user,
        builder: (_, AsyncSnapshot<auth.User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final auth.User? user = snapshot.data;

            return user == null
                ? const LoginPage()
                : HomePage(
                    user: user,
                  );
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
