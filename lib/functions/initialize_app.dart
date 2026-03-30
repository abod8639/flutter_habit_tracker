import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/controller/theme_controller.dart';
import 'package:habit_tracker/controller/trend_chart_controller.dart';
import 'package:habit_tracker/controller/lang_controller.dart';
import 'package:habit_tracker/data/habit_storage.dart';
import 'package:habit_tracker/data/lang_storage.dart';
import 'package:habit_tracker/data/theme_storage.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:habit_tracker/controller/notification_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Hive.initFlutter();
    Hive.registerAdapter(HabitModelAdapter());

    try {
      final notificationService = NotificationService();
      await notificationService.init();
      await notificationService.requestPermissions();
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }

    await Future.wait([
      Hive.openBox(HabitStorage.boxName),
      Hive.openBox(ThemeStorageService.themeBox),
      Hive.openBox(LangStorage.boxName),
    ]);

    Get.put(HabitController());
    Get.put(ThemeController());
    Get.put(LangController());
    Get.put(TrendChartState());
    Get.put(NotificationController());
  } catch (e, stack) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stack');
    throw Exception('Failed to initialize app: $e');
  }
}
