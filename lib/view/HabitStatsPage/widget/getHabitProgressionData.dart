import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';

Map<String, List<double>> getHabitProgressionData() {
  final controller = Get.find<HabitController>();
  final Map<String, List<double>> habitData = {};
  final habits = controller.db.todaysHabitList;

  if (habits.isEmpty) return habitData;

  // Get the dates to show in the chart (last 7 days)
  final now = DateTime.now();
  final List<DateTime> dates = List.generate(
    7, // Show last 7 days
    (index) => now.subtract(Duration(days: 6 - index)), // Count up to today
  );

  // Initialize progress tracking for each habit
  for (final habit in habits) {
    final String habitName = habit[0];
    habitData[habitName] = List<double>.filled(7, 0.0);
  }

  // For each date, check each habit's completion status
  for (var i = 0; i < dates.length; i++) {
    final date = dates[i];
    final normalizedDate = DateTime(date.year, date.month, date.day);

    for (final habit in habits) {
      final String habitName = habit[0];
      // Check if the habit was completed on this date using the heatmap data
      final int? completionValue = controller.db.heatmapDateSet[normalizedDate];

      if (completionValue != null) {
        // If we have data for this date, mark as completed (1.0) if strength > 0.5
        habitData[habitName]![i] = completionValue > 5 ? 1.0 : 0.0;
      }
    }
  }

  debugPrint(
    '📊 Habit progression data calculated for ${habitData.length} habits',
  );

  debugPrint(
    '📊 Habit progression data calculated for ${habitData.length} habits',
  );

  return habitData;
}
