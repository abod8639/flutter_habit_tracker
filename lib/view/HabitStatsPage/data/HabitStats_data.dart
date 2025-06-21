import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';

List<FlSpot> prepareTrendData() {
  final controller = Get.put(HabitController());
  final habits = controller.db.todaysHabitList;

  if (habits.isEmpty) {
    return [const FlSpot(0, 0)];
  }

  // Get the last 7 days
  final now = DateTime.now();
  final List<DateTime> dates = List.generate(
    7,
    (index) => now.subtract(Duration(days: 6 - index)),
  );

  List<FlSpot> trendSpots = [];

  // For each day, calculate the overall completion percentage
  for (int i = 0; i < dates.length; i++) {
    final date = dates[i];
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Get completion data from heatmap
    final int? completionValue = controller.db.heatmapDateSet[normalizedDate];
    final double percentage =
        completionValue != null ? completionValue / 10.0 : 0.0;

    trendSpots.add(FlSpot(i.toDouble(), percentage.clamp(0.0, 1.0)));
  }

  return trendSpots;
}

List<String> prepareTrendLabels(int day) {
  final now = DateTime.now();

  // Get last 7 days for consistent labeling
  return List.generate(day, (index) {
    final date = now.subtract(Duration(days: 6 - index));
    return '${date.day}/${date.month}';
  });
}

double getMaxTrendValue() {
  // We now use a fixed max value of 1.0 (100%) since we're showing percentages
  return 1.0;
}

Map<String, dynamic> calculateStats() {
  final controller = Get.put(HabitController());

  // Use public methods to get habits data instead of accessing private fields
  final int totalHabits = controller.db.todaysHabitList.length;
  final int completedHabits = controller.db.getCompletedHabits().length;
  final double completionRate =
      totalHabits > 0 ? (completedHabits / totalHabits) * 100 : 0;

  return {
    'totalHabits': totalHabits,
    'completedHabits': completedHabits,
    'completionRate': completionRate,
    'streak': controller.dayCount.value,
  };
}

List<Map<String, dynamic>> prepareChartData() {
  final controller = Get.put(HabitController());

  // Use the public methods instead of directly accessing private fields
  final List<dynamic> habitsList = controller.db.todaysHabitList;

  return List.generate(habitsList.length, (index) {
    final habit = habitsList[index];
    return {
      'id': index.toString(),
      'habit': habit[0],
      'completed': habit[1],
      'createdAt': DateTime.now(),
    };
  });
}

Map<String, List<FlSpot>> prepareTodayHabitTrends() {
  final controller = Get.find<HabitController>();
  final habitsList = controller.db.todaysHabitList;

  if (habitsList.isEmpty) return {};

  final Map<String, List<FlSpot>> habitProgressMap = {};
  final now = DateTime.now();

  // Get the last 7 days
  final List<DateTime> dates = List.generate(
    7,
    (index) => now.subtract(Duration(days: 6 - index)),
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
