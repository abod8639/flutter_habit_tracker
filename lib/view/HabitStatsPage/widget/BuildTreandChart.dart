import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';

final HabitController habitController = Get.find<HabitController>();

Widget BuildTrendChart(
  BuildContext context,
  List<FlSpot> trendSpots,
  List<String> trendLabels,
  double maxTrendValue,
) {
  // Skip if no data is available
  if (trendSpots.isEmpty ||
      trendSpots.length <= 1 && trendSpots[0] == const FlSpot(0, 0)) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: Center(
            child: Text(
              'Not enough data to display trends',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  // Prepare data for the top 3 most frequent habits
  // final Map<String, List<double>> habitProgression =
  _getHabitProgressionData();
  // final List<String> habitNames = habitProgression.keys.take(3).toList();
  // final List<Color> lineColors = [Colors.purple, Colors.blue, Colors.green];

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < trendLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              trendLabels[index],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 == 0 && value <= maxTrendValue) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                minX: 0,
                maxX: trendLabels.length - 1.0,
                minY: 0,
                maxY: maxTrendValue,
                lineBarsData: [
                  // Overall trend line
                  LineChartBarData(
                    spots: trendSpots,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const SizedBox(height: 16),
          // const Text(
          //   'Habit Completion Trend',
          //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          // ),
        ],
      ),
    ),
  );
}

Map<String, List<double>> _getHabitProgressionData() {
  Map<String, List<double>> habitData = {};

  // Get the historical data from the heatmap
  final Map<DateTime, int> heatmapData = habitController.db.heatmapDateSet;
  if (heatmapData.isEmpty) {
    return habitData;
  }

  // Process habit completion data by day
  // We need to use the actual habit names and their completion history
  for (var habit in habitController.db.todaysHabitList) {
    String habitName = habit[0];
    habitData[habitName] = [];

    // Create progression data for each habit
    // Since we don't have actual historical data per habit in this model,
    // we'll use the available overall completion rate as a baseline
    final List<DateTime> sortedDates =
        heatmapData.keys.toList()..sort((a, b) => a.compareTo(b));
    final int daysToShow = sortedDates.length > 6 ? 6 : sortedDates.length;
    final List<DateTime> recentDates = sortedDates.sublist(
      sortedDates.length - daysToShow,
    );

    for (DateTime date in recentDates) {
      double value = (heatmapData[date] ?? 0) / 10.0; // Convert to a 0-10 scale
      habitData[habitName]?.add(value);
    }
  }

  return habitData;
}
