import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/langController.Getx.dart';
import 'package:habit_tracker/functions/initializeApp.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/services/syncHiveToSupabase.dart';
import 'package:habit_tracker/utils/restart_widget.dart';
import 'package:habit_tracker/view/ErrorApp.dart';
import 'package:habit_tracker/view/homepage/HomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SupabaseService.initialize();

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

// final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LangController controllerLanguage = Get.put(LangController());
    return GetMaterialApp(
      locale: Locale(controllerLanguage.language.value),
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
