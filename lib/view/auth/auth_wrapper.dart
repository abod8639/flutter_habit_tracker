import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/view/auth/login_page.dart';
import 'package:habit_tracker/view/homepage/HomeScreen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show login page if not authenticated
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }

        // Show home screen if authenticated
        return const HomeScreen();
      },
    );
  }
}
