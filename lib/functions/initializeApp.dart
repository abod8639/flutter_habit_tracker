import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/controller/ThemeController.dart';
import 'package:habit_tracker/controller/langController.dart';
import 'package:habit_tracker/services/HabitStorage.dart';
import 'package:habit_tracker/services/lang_storage.dart';
import 'package:habit_tracker/services/theme_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(HabitStorage.boxName),
      Hive.openBox(ThemeStorageService.themeBox),
      Hive.openBox(LangStorage.boxName),
    ]);

    Get.put(HabitController());
    Get.put(ThemeController());
    Get.put(Langcontroller());
  } catch (e, stack) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stack');
    throw Exception('Failed to initialize app: $e');
  }
}
