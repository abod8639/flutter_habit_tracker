// habit_storage.dart
import 'package:hive/hive.dart';

class HabitStorage {
  static const String boxName = "Habit_db";
  static const String todoListKey = "TODOLIST";
  static const String lastResetDateKey = "LAST_RESET_DATE";
  static const String dayCountKey = "DAY_COUNT";
  static const String startDayKey = "START_DAY";
}

void initializeBox(Box box, dynamic db) {
  if (box.get(HabitStorage.todoListKey) == null) {
    db.createDefaultData();
    box.put(HabitStorage.dayCountKey, 1);
  } else {
    db.loadData();
  }
}

void saveLastResetDate(Box box, DateTime date) {
  box.put(HabitStorage.lastResetDateKey, date.toIso8601String());
}

DateTime? getLastResetDate(Box box) {
  final String? dateStr = box.get(HabitStorage.lastResetDateKey);
  return dateStr != null ? DateTime.parse(dateStr) : null;
}
