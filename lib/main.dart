import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pollstrix/custom/custom_error_page.dart';
import 'package:pollstrix/l10n/l10n.dart';
import 'package:pollstrix/screens/feed_content_page.dart';
import 'package:pollstrix/screens/home_page.dart';
import 'package:pollstrix/screens/login_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:pollstrix/services/connectivity_provider.dart';
import 'package:pollstrix/services/locale_service.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:pollstrix/screens/register_page.dart';
import 'package:pollstrix/screens/forgot_password_page.dart';
import 'package:pollstrix/screens/reset_password_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        // ChangeNotifierProvider<ConnectivityProvider>(
        //     create: (context) => ConnectivityProvider())
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
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),
            '/reset-password': (context) => const ResetPasswordPage(),
            '/feedcontent': (context) => const FeedContentPage()
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
    final AuthenticationService authService = Provider.of(context);

    return StreamBuilder<String>(
        stream: authService.onAuthStateChanges,
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final bool signedIn = snapshot.hasData;

            return signedIn ? const HomePage() : const LoginPage();
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

// class CustomRoute {
//   static Route<dynamic> allRoutes(RouteSettings settings) {
//     return MaterialPageRoute(builder: (context) {
//       final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;

//       if (!isOnline) {
//         return const ErrorPage(
//           message: 'No connection',
//           icon: Icon(
//             Icons.wifi_off_rounded,
//             color: Colors.red,
//             size: 30,
//           ),
//         );
//       }

//       switch (settings.name) {
//         case '/login':
//           return const LoginPage();
//         case '/register':
//           return const RegisterPage();
//         case '/forgot-password':
//           return const ForgotPasswordPage();
//         case '/reset-password':
//           return const ResetPasswordPage();
//         case '/feedcontent':
//           return const FeedContentPage();
//       }

//       return const ErrorPage(
//         message: 'Under Construction',
//         icon: Icon(
//           Icons.error_outline_rounded,
//           color: Colors.red,
//           size: 30,
//         ),
//       );
//     });
//   }
// }


            // AppLocalizations.delegate,
