import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/features/theme/presentation/controllers/theme_controller.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/setting_binding.dart';
import 'package:habit_tracker/data/habit_storage.dart';
import 'package:habit_tracker/data/lang_storage.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/data/theme_storage.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initializeApp() async {
  try {
    // 1. Initialize Hive
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      try {
        Hive.registerAdapter(HabitModelAdapter());
      } catch (_) {}
    }

    // 2. Open Boxes with corruption recovery
    await _openBoxSafely(HabitStorage.boxName);
    await _openBoxSafely(ThemeStorageService.themeBox);
    await _openBoxSafely(LangStorage.boxName);
    await _openBoxSafely(SettingsStorage.boxName);

    // 3. Load Env (Non-critical)
    try {
      await dotenv.load(fileName: '.env');
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

    // 5. Initialize Dependencies and Controllers
    SettingBinding().dependencies();
    
    Get.put(ThemeController());
    Get.put(HabitController());
  } catch (e, stack) {
    debugPrint('FATAL initialization error: $e');
    debugPrint('Stack trace: $stack');
    throw Exception('Failed to initialize app: $e');
  }
}

/// Opens a Hive box safely. If the box file is corrupted (RangeError or
/// HiveError), deletes the corrupted file and reopens a fresh empty box.
Future<void> _openBoxSafely(String boxName) async {
  if (Hive.isBoxOpen(boxName)) return;

  try {
    await Hive.openBox(boxName);
  } catch (e) {
    debugPrint(
      '⚠️ Box "$boxName" is corrupted ($e). Deleting and recreating...',
    );
    await _deleteCorruptedBox(boxName);
    // Open fresh empty box
    await Hive.openBox(boxName);
    debugPrint('✅ Box "$boxName" recreated successfully.');
  }
}

/// Deletes the corrupted Hive box file from disk.
Future<void> _deleteCorruptedBox(String boxName) async {
  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    final boxFile = File('${appDocDir.path}/$boxName.hive');
    final lockFile = File('${appDocDir.path}/$boxName.lock');

    if (await boxFile.exists()) await boxFile.delete();
    if (await lockFile.exists()) await lockFile.delete();

    debugPrint('🗑️ Deleted corrupted box files for "$boxName"');
  } catch (e) {
    debugPrint('❌ Failed to delete corrupted box "$boxName": $e');
  }
}
