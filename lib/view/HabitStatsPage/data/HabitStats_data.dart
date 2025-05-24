import 'package:fl_chart/fl_chart.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildTreandChart.dart';

List<FlSpot> prepareTrendData() {
  final Map<DateTime, int> heatmapData = habitController.db.heatmapDateSet;
  if (heatmapData.isEmpty) {
    return [const FlSpot(0, 0)];
  }

  final List<DateTime> sortedDates =
      heatmapData.keys.toList()..sort((a, b) => a.compareTo(b));

  final int daysToShow = sortedDates.length > 10 ? 10 : sortedDates.length;
  final List<DateTime> recentDates = sortedDates.sublist(
    sortedDates.length - daysToShow,
  );

  List<FlSpot> trendSpots = [];

  for (int i = 0; i < recentDates.length; i++) {
    final DateTime date = recentDates[i];
    final int value = heatmapData[date] ?? 0;
    final double percentage = value.toDouble();
    trendSpots.add(FlSpot(i.toDouble(), percentage));
  }

  return trendSpots;
}

List<String> prepareTrendLabels() {
  final Map<DateTime, int> heatmapData = habitController.db.heatmapDateSet;
  if (heatmapData.isEmpty) {
    return ['No data'];
  }

  final List<DateTime> sortedDates =
      heatmapData.keys.toList()..sort((a, b) => a.compareTo(b));

  final int daysToShow = sortedDates.length > 10 ? 10 : sortedDates.length;
  final List<DateTime> recentDates = sortedDates.sublist(
    sortedDates.length - daysToShow,
  );

  return recentDates.map((date) => '${date.day}/${date.month}').toList();
}

double getMaxTrendValue() {
  final Map<DateTime, int> heatmapData = habitController.db.heatmapDateSet;
  if (heatmapData.isEmpty) return 70;

  double maxValue = 0;
  for (final value in heatmapData.values) {
    if (value > maxValue) {
      maxValue = value.toDouble();
    }
  }
  return maxValue + 20 > 100 ? 100 : maxValue + 20;
}

Map<String, dynamic> calculateStats(HabitController controller) {
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

List<Map<String, dynamic>> prepareChartData(HabitController controller) {
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
