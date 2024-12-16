import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stockiteasy/pages/home_page.dart';
import 'package:stockiteasy/pages/login_page.dart';
import 'package:stockiteasy/pages/register_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage(showRegisterPage: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage(showLoginPage: () {
                  Navigator.pop(context);
                })),
              );
            });
          }
        },
      ),
    );
  }
}
