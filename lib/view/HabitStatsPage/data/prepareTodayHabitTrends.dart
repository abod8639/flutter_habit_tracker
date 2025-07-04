import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';

Map<String, List<FlSpot>> prepareTodayHabitTrends(int days) {
  final controller = Get.find<HabitController>();
  final habitsList = controller.db.todaysHabitList;

  if (habitsList.isEmpty) return {};

  final Map<String, List<FlSpot>> habitProgressMap = {};
  final now = DateTime.now();

  // Get the last days days
  final List<DateTime> dates = List.generate(
    days,
    (index) => now.subtract(Duration(days: days - 1 - index)),
  );

  // Get the history map
  final historyMap = controller.habitHistoryMap.value;

  for (var habit in habitsList) {
    final String habitName = habit[0];
    final List<FlSpot> spots = [];

    // For each day, get the habit's completion status from history
    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Check if we have history data for this habit and date
      final bool? completed = historyMap[habitName]?[normalizedDate];

      // For today, use current status if no history entry exists
      if (i == dates.length - 1 && completed == null) {
        spots.add(FlSpot(i.toDouble(), habit[1] ? 1.0 : 0.0));
      } else {
        // For other days or if history exists, use the history data
        spots.add(FlSpot(i.toDouble(), completed == true ? 1.0 : 0.00));
      }
    }

    habitProgressMap[habitName] = spots;
  }

  return habitProgressMap;
}
