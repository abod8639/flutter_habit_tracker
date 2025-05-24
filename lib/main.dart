import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/initializeApp.dart';
import 'package:habit_tracker/view/ErrorApp.dart';
import 'package:habit_tracker/view/homepage/HomeScreen.dart';

// Constants for box names

void main() {
  runZonedGuarded(
    () async {
      await initializeApp();
      runApp(const MyApp());
    },
    (error, stack) {
      debugPrint('Error during app execution: $error');
      debugPrint('Stack trace: $stack');
      runApp(ErrorApp(error: error.toString()));
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      defaultTransition: Transition.fadeIn,
      smartManagement: SmartManagement.full,

      home: const HomeScreen(),
    );
  }
}
