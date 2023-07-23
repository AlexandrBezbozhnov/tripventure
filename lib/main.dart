import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tripventure/screens/account_screen.dart';
import 'package:tripventure/screens/home_screen.dart';
import 'package:tripventure/screens/login_screen.dart';
import 'package:tripventure/screens/reset_password_screen.dart';
import 'package:tripventure/screens/signup_screen.dart';
import 'package:tripventure/screens/verify_email_screen.dart';
import 'package:tripventure/services/firebase_streem.dart';



 Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();

// Получаем текущую тему телефона
final systemTheme = WidgetsBinding.instance.window.platformBrightness;

// Назначем тему приложения в зависимости от текущей темы телефона
runApp(
MaterialApp(
debugShowCheckedModeBanner: false,
theme: ThemeData(
pageTransitionsTheme: const PageTransitionsTheme(builders: {
TargetPlatform.android: CupertinoPageTransitionsBuilder(),
}),
brightness: systemTheme == Brightness.light ? Brightness.light : Brightness.dark,
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