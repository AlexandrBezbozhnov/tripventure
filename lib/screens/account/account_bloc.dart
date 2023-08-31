import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountBackEnd {
  Future<void> signOutAndNavigateToHome(BuildContext context) async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }
}
