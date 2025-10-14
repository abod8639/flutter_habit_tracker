// habit_storage.dart
import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/models/date_time.dart';
import 'package:hive/hive.dart';

/// Storage constants and helper methods for the Habit Tracker app
class HabitStorage {
  // Box name
  static const String boxName = "Habit_db";

  // Storage keys
  static const String habitListKey = "TODOLIST";
  static const String lastResetDateKey = "LAST_RESET_DATE";
  static const String dayCountKey = "DAY_COUNT";
  static const String startDayKey = "START_DAY";
  static const String lastSavedDateKey = "LAST_SAVED_DATE";
  static const String habitStrengthPrefix = "TODAY_HABIT";

  // Default values
  static const int defaultDayCount = 1;

  static List<HabitModel> defaultHabits = [
    HabitModel(
      name: "1 ",//"${S.current.defaultHabits1}",
      isCompleted: false,
      createdAt: DateTime.now(),
    ),

    HabitModel(
      name: "2 ${S.current.defaultHabits2}",
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    HabitModel(
      name: "3 ${S.current.defaultHabits3}",
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
  ];
}

/// Initialize the Habit database and ensure data is loaded properly
Future<void> initializeBox(Box box, dynamic db) async {
  try {
    if (box.get(HabitStorage.habitListKey) == null) {
      // First time initialization
      db.createDefaultData();
      box.put(HabitStorage.dayCountKey, HabitStorage.defaultDayCount);
      box.put(HabitStorage.startDayKey, todaysDateFormatted());

      // Set initial last reset date
      final now = DateTime.now();
      saveLastResetDate(box, now);

      // Log initialization
      debugPrint('🔄 Habit Tracker initialized with default data');
    } else {
      // Load existing data
      db.loadData();
      debugPrint('📋 Existing habit data loaded successfully');
    }

    // Always make sure day count exists
    if (box.get(HabitStorage.dayCountKey) == null) {
      box.put(HabitStorage.dayCountKey, HabitStorage.defaultDayCount);
    }

    // Always ensure lastSavedDate is initialized
    if (box.get(HabitStorage.lastSavedDateKey) == null) {
      box.put(HabitStorage.lastSavedDateKey, todaysDateFormatted());
    }
  } catch (e) {
    debugPrint('❌ Error initializing Habit Tracker: $e');
    // Attempt recovery
    _recoverFromInitializationError(box, db);
  }
}

/// Save the last reset date to track habit resets
void saveLastResetDate(Box box, DateTime date) {
  box.put(HabitStorage.lastResetDateKey, date.toIso8601String());
}

/// Get the last reset date or null if not set
DateTime? getLastResetDate(Box box) {
  try {
    final String? dateStr = box.get(HabitStorage.lastResetDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  } catch (e) {
    debugPrint('❌ Error parsing last reset date: $e');
    return null;
  }
}

/// Recovery method to handle initialization errors
void _recoverFromInitializationError(Box box, dynamic db) {
  try {
    // Reset to default state
    box.put(HabitStorage.habitListKey, null);
    db.createDefaultData();
    box.put(HabitStorage.dayCountKey, HabitStorage.defaultDayCount);
    box.put(HabitStorage.startDayKey, todaysDateFormatted());
    saveLastResetDate(box, DateTime.now());
    debugPrint('🔄 Recovery completed - reset to default state');
  } catch (e) {
    debugPrint('❌ Recovery failed: $e');
  }
}

/// Delete all data from the Habit database
