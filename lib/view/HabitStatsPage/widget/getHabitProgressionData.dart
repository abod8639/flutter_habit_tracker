import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';

Map<String, List<double>> getHabitProgressionData() {
  final HabitController habitController = Get.put(HabitController());

  Map<String, List<double>> habitData = {};

  // Get current habits
  final habits = habitController.db.todaysHabitList;
  if (habits.isEmpty) {
    return habitData;
  }

  // Calculate date range for progression data
  final now = DateTime.now();
  final int dayCount = habitController.dayCount.value;
  final List<DateTime> recentDates = List.generate(
    dayCount,
    (index) => now.subtract(Duration(days: dayCount - 1 - index)),
  );

  // Get completion history for each habit
  for (var habit in habits) {
    final String habitName = habit[0];
    final List<double> progressionData = [];
    habitData[habitName] = progressionData;

    for (final date in recentDates) {
      // Normalize date to start of day for consistent comparison
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Get completion data from heatmap (scaled between 0 and 1)
      final int? completionValue =
          habitController.db.heatmapDateSet[normalizedDate];
      final double completionRate =
          completionValue != null
              ? (completionValue / 10.0).clamp(0.0, 10.0)
              : 0.0;
      progressionData.add(completionRate);
    }
  }

  return habitData;
}
