import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/l10n/l10n.dart';
import 'package:pollstrix/screens/polls/feed_content_page.dart';
import 'package:pollstrix/screens/forgot_password_page.dart';
import 'package:pollstrix/screens/home_page.dart';
import 'package:pollstrix/screens/login_page.dart';
import 'package:pollstrix/screens/polls/post_poll_page.dart';
import 'package:pollstrix/screens/register_page.dart';
import 'package:pollstrix/screens/profile/reset_password_page.dart';
import 'package:pollstrix/screens/verify_email_page.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:pollstrix/services/locale_service.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

  FlutterNativeSplash.remove();

  return runApp(ChangeNotifierProvider<ThemeProvider>(
    create: (_) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(create: (_) => AuthenticationService()),
        Provider(create: (_) => FirebaseFirestore.instance),
        ChangeNotifierProvider<LocaleProvider>(
            create: (context) => LocaleProvider()),
      ],
      child: Consumer<ThemeProvider>(builder: (context, provider, child) {
        final localeProvider = Provider.of<LocaleProvider>(context);

        return OverlaySupport.global(
            child: MaterialApp(
          title: 'Pollstrix',
          debugShowCheckedModeBanner: false,
          themeMode: provider.themeMode,
          theme: MyTheme.lightTheme,
          darkTheme: MyTheme.darkTheme,
          locale: localeProvider.locale,
          supportedLocales: L10n.all,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthenticationWrapper(),
            loginRoute: (context) => const LoginPage(),
            registerRoute: (context) => const RegisterPage(),
            forgotPasswordRoute: (context) => const ForgotPasswordPage(),
            resetPasswordRoute: (context) => const ResetPasswordPage(),
            verifyEmailRoute: (context) => const VerifyEmailPage(),
            homeRoute: (context) => const HomePage(),
            feedContentRoute: (context) => const FeedContentPage(),
            postNewPollRoute: (context) => const PostPollPage()
          },
        ));
      }),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const HomePage();
                } else {
                  return const VerifyEmailPage();
                }
              } else {
                return const LoginPage();
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        });
  }
}
