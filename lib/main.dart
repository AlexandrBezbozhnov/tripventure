import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tripventure/screens/account/account_screen.dart';
import 'package:tripventure/screens/home/home_screen.dart';
import 'package:tripventure/screens/login/login_screen.dart';
import 'package:tripventure/screens/login/reset_password_screen.dart';
import 'package:tripventure/screens/login/signup_screen.dart';
import 'package:tripventure/screens/login/verify_email_screen.dart';
import 'package:tripventure/services/firebase_streem.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final systemTheme = WidgetsBinding.instance.window.platformBrightness;
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
        brightness: systemTheme == Brightness.light
            ? Brightness.light
            : Brightness.dark,
      ),
      routes: {
        '/': (context) => const FirebaseStream(),
        '/home': (context) => const HomeScreen(),
        '/account': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
      },
      initialRoute: '/',
    ),
  );
}
