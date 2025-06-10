import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/langController.dart';
import 'package:habit_tracker/functions/initializeApp.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/utils/restart_widget.dart';
import 'package:habit_tracker/view/ErrorApp.dart';
import 'package:habit_tracker/view/homepage/HomeScreen.dart';

// Constants for box names

void main() {
  runZonedGuarded(
    () async {
      await initializeApp();
      runApp(RestartWidget(child: const MyApp()));
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
    final Langcontroller controllerlanguage = Get.put(Langcontroller());
    return GetMaterialApp(
      locale: Locale(controllerlanguage.language.value),
      // const Locale('ar'),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      defaultTransition: Transition.fadeIn,
      smartManagement: SmartManagement.full,

      home: const HomeScreen(),
    );
  }
}
