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

    // 1. Initialize Hive First (Critical for Data Persistence)
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) { // Example check, using name/typeId is safer
      // Only register if not already there to avoid errors on hot restart
      try { Hive.registerAdapter(HabitModelAdapter()); } catch(_) {}
    }

    // 2. Open Boxes as soon as possible
    await Future.wait([
      Hive.openBox(HabitStorage.boxName),
      Hive.openBox(ThemeStorageService.themeBox),
      Hive.openBox(LangStorage.boxName),
    ]);

    // 3. Load Env (Non-critical, wrap in try-catch)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Failed to load .env: $e');
    }

    // 4. Initialize Notifications (Non-critical)
    try {
      final notificationService = NotificationService();
      await notificationService.init();
      await notificationService.requestPermissions();
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }

    // 5. Initialize Controllers
    Get.put(ThemeController());
    Get.put(LangController());
    Get.put(HabitController());
    Get.put(TrendChartState());
    Get.put(NotificationController());
  } catch (e, stack) {
    debugPrint('FATAL initialization error: $e');
    debugPrint('Stack trace: $stack');
    // We throw to let main.dart show the ErrorApp
    throw Exception('Failed to initialize app: $e');
  }
}
