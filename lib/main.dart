import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/lang_controller.dart';
import 'package:habit_tracker/controller/theme_controller.dart';
import 'package:habit_tracker/firebase_options.dart';
import 'package:habit_tracker/functions/initialize_app.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/utils/restart_widget.dart';
import 'package:habit_tracker/view/ErrorApp.dart';
import 'package:habit_tracker/view/auth/auth_wrapper.dart';

Future<void> main() async {
  // CRITICAL: Must be called BEFORE runZonedGuarded to avoid Zone mismatch
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(
    () async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await initializeApp();
      runApp(RestartWidget(child: const MyApp()));
    },
    (error, stack) {
      debugPrint('Error during app execution: $error');
      debugPrint('Stack trace: $stack');
      // Use addPostFrameCallback to run in the correct zone
      WidgetsBinding.instance.addPostFrameCallback((_) {
        runApp(ErrorApp(error: error.toString()));
      });
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LangController controllerLanguage = Get.put(LangController());
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
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

        theme: themeController.lightTheme.value,
        darkTheme: themeController.darkTheme.value,
        themeMode: themeController.themeMode.value,

        home: const AuthWrapper(),
      ),
    );
  }
}
