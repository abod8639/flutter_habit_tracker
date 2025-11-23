import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';

Map<String, List<double>> getHabitProgressionDataForDays(int days) {
  final controller = Get.find<HabitController>();
  final Map<String, List<double>> habitData = {};
  final habits = controller.db.todaysHabitList;
  // final habits = controller.db.

  if (habits.isEmpty) return habitData;

  final now = DateTime.now();
  final List<DateTime> dates = List.generate(
    days,
    (index) => DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1 - index)),
  );

  for (final habit in habits) {
    final String habitName = habit.name;
    habitData[habitName] = List<double>.filled(days, 0.0);
  }

  for (int i = 0; i < dates.length; i++) {
    final date = dates[i];

    for (final habit in habits) {
      final String habitName = habit.name;
      final int? completionValue = controller.db.heatmapDateSet[date];

      if (completionValue != null) {
        habitData[habitName]![i] = completionValue > 5 ? 1.0 : 0.0;
      }
    }
  }

  debugPrint(
    '📊 Habit progression for last $days days calculated (${habitData.length} habits)',
  );

  return habitData;
}

Map<String, List<double>> getLast7DaysHabitProgression() {
  return getHabitProgressionDataForDays(7);
}

Map<String, List<double>> getLast30DaysHabitProgression() {
  return getHabitProgressionDataForDays(30);
}
