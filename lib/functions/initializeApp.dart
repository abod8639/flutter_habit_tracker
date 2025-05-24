import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/controller/ThemeController.dart';
import 'package:habit_tracker/services/theme_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
