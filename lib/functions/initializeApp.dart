import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';
import 'package:habit_tracker/controller/ThemeController.Getx.dart';
import 'package:habit_tracker/controller/langController.Getx.dart';
import 'package:habit_tracker/data/HabitStorage.dart';
import 'package:habit_tracker/data/lang_storage.dart';
import 'package:habit_tracker/data/theme_storage.dart';
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
