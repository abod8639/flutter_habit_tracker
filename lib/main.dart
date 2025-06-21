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
import 'package:supabase_flutter/supabase_flutter.dart';

// Constants for box names

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://dydnmakiydczgbrkxxlf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR5ZG5tYWtpeWRjemdicmt4eGxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAzODI1MDIsImV4cCI6MjA2NTk1ODUwMn0.K3oaQytier4iZI8iY3AT7-W1BSP6ePheImj_MpuK0PU',
  );
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

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Langcontroller controllerlanguage = Get.put(Langcontroller());
    return GetMaterialApp(
      locale: Locale(controllerlanguage.language.value),
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

      // home: const SupaEmailAuthWidget(),
      home: const HomeScreen(),
    );
  }
}
