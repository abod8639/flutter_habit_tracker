import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';

List<FlSpot> prepareTrendData(int days) {
  final controller = Get.put(HabitController());
  final habits = controller.db.todaysHabitList;

  if (habits.isEmpty) {
    return [const FlSpot(0, 0)];
  }

  // Get the last 7 days
  final now = DateTime.now();
  final List<DateTime> dates = List.generate(
    days,
    (index) => now.subtract(Duration(days: days - 1 - index)),
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
