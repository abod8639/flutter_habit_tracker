// habit_actions.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/data/habit_db.dart';

void resetAllHabits(Habitdb db) {
  for (var habit in db.todaysHabitList) {
    habit[1] = false;
  }
  db.updateData();
  Get.snackbar(
    'Habits Reset',
    'All habits have been reset for the new day',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.green.withOpacity(0.7),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
  );
}
