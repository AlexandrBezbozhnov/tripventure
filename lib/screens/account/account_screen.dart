import 'package:flutter/material.dart';
import 'package:tripventure/screens/account/account_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final AccountBackEnd accountBackEnd = AccountBackEnd(); // Создаем экземпляр класса бэк-энда

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios, // Добавьте кастомные иконки при необходимости
          ),
        ),
        title: const Text('Аккаунт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Открыть корзину покупок',
            onPressed: () => accountBackEnd.signOutAndNavigateToHome(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ваш Email: ${user?.email}'),
            TextButton(
              onPressed: () => accountBackEnd.signOutAndNavigateToHome(context),
              child: const Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}
