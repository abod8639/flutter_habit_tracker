import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/controller/ThemeController.dart';
import 'package:habit_tracker/services/HabitStorage.dart';
import 'package:habit_tracker/services/theme_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(HabitStorage.boxName),
      Hive.openBox(ThemeStorageService.themeBox),
    ]);
    Get.put(HabitController());
    Get.put(ThemeController());
  } catch (e, stack) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stack');
    throw Exception('Failed to initialize app: $e');
  }
}
