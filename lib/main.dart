import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/controller/theme_controller.dart';
import 'package:habit_tracker/services/theme_storage.dart';
import 'package:habit_tracker/view/homepage/Responsive/Phone.dart';
import 'package:habit_tracker/view/homepage/Responsive/Tablet.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

Future<void> initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive
    await Hive.initFlutter();

    // Open all required boxes
    await Future.wait([
      Hive.openBox("Habit_db"),
      Hive.openBox(ThemeStorageService.themeBox),
    ]);

    // Initialize Get services and controllers
    await initializeServices();
  } catch (e, stack) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stack');
    throw Exception('Failed to initialize app: $e');
  }
}

Future<void> initializeServices() async {
  // Initialize controllers
  Get.put(HabitController());
  Get.put(ThemeController());
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
      builder: (context, child) {
        // Apply any global styling or error handlers here
        return ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
      getPages: [
        // Add your routes here
        GetPage(name: '/', page: () => const HomeScreen()),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HabitController>(
      builder: (controller) => _buildResponsiveLayout(context, controller),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    HabitController controller,
  ) {
    return controller.isPhone(context) ? const Phone() : const Tablet();
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, this.error = 'Failed to initialize app'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'An error occurred',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
