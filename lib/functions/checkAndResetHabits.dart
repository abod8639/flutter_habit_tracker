import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';
import 'package:habit_tracker/data/HabitStorage.dart';
import 'package:habit_tracker/functions/HabitUtils.dart';
import 'package:habit_tracker/functions/resetAllHabits.dart';
import 'package:habit_tracker/models/date_time.dart';

/// Check if habits need to be reset for a new day
void checkAndResetHabits() {
  final HabitController c = Get.put(HabitController());
  try {
    if (shouldResetHabits(c.lastResetDate.value)) {
      debugPrint('🔄 Resetting habits for new day');

      // Save current state to history before reset
      final habits = c.db.todaysHabitList;
      final now = DateTime.now();
      final normalizedDate = DateTime(now.year, now.month, now.day);
      final currentHistory = Map<String, Map<DateTime, bool>>.from(
        c.habitHistoryMap.value,
      );
      final todayStr = convertDateTimeToString(normalizedDate);

      // Save each habit's current state to history
      for (var habit in habits) {
        final String habitName = habit.name;
        final bool isCompleted = habit.isCompleted;

        // Save to history map
        if (!currentHistory.containsKey(habitName)) {
          currentHistory[habitName] = {};
        }
        currentHistory[habitName]![normalizedDate] = isCompleted;

        // Save to database
        final String historyKey = "${habitName}_$todayStr";
        c.myBox.put(historyKey, isCompleted);
      }
      c.habitHistoryMap.value = currentHistory;

      // Perform reset
      c.incrementDayCount();
      resetAllHabits(c.db);
      c.lastResetDate.value = DateTime.now();
      saveLastResetDate(c.myBox, c.lastResetDate.value!);

      // Make sure all habits start as not completed for the new day
      final newDate = DateTime.now();
      final newNormalizedDate = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
      );
      for (var habit in habits) {
        final String habitName = habit.name;
        currentHistory[habitName]![newNormalizedDate] = false;
      }
      c.habitHistoryMap.value = currentHistory;
    }
  } catch (e) {
    debugPrint('❌ Error checking/resetting habits: $e');
  }
}
