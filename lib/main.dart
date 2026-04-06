import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/bindings/initial_binding.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/lang_controller.dart';
import 'package:habit_tracker/features/theme/presentation/controllers/theme_controller.dart';
import 'package:habit_tracker/firebase_options.dart';
import 'package:habit_tracker/core/functions/initialize_app.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/utils/restart_widget.dart';
import 'package:habit_tracker/core/error/error_app.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/auth_wrapper.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await initializeApp();

      InitialBinding().dependencies();

      runApp(RestartWidget(child: const MyApp()));
    },
    (error, stack) {
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
    // These will now be found correctly because InitialBinding() was called in main()
    final LangController controllerLanguage = Get.find<LangController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        initialBinding: InitialBinding(), // Already called in main()
        locale: Locale(controllerLanguage.language.value),

        localizationsDelegates: const [
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
