import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/view/auth/loginpage/login_page.dart';
import 'package:habit_tracker/view/homepage/HomeScreen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SettingsStorage _settingsStorage = SettingsStorage();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    await _settingsStorage.init();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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

        // Check if user has skipped login
        final hasSkipped = _settingsStorage.hasSkippedLogin;

        // Show login page if not authenticated and hasn't skipped
        if ((!snapshot.hasData || snapshot.data == null) && !hasSkipped) {
          return const LoginPage();
        }

        // Show home screen if authenticated or has skipped login
        return const HomeScreen();
      },
    );
  }
}
