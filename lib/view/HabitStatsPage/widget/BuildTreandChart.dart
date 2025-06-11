import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/generated/l10n.dart';

final HabitController habitController = Get.put(HabitController());

Widget BuildTrendChart({
  required List<FlSpot> trendSpots,
  required List<String> trendLabels,
  required double maxTrendValue,
}) {
  // Skip if no data is available
  if (trendSpots.isEmpty ||
      trendSpots.length <= 1 && trendSpots[0] == const FlSpot(0, 0)) {
    return Builder(
      builder: (context) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  S.of(context).TrendCharisEmpty,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Get progression data for individual habits
  final Map<String, List<double>> habitProgression = _getHabitProgressionData();
  final List<String> habitNames = habitProgression.keys.toList();
  final List<Color> lineColors = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.purpleAccent,
  ];

  return Builder(
    builder: (context) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  S.of(context).monthly,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              LineChartBox(
                maxTrendValue: maxTrendValue,
                trendLabels: trendLabels,
                habitNames: habitNames,
                habitProgression: habitProgression,
                lineColors: lineColors,
              ),
              const SizedBox(height: 16),
              // Legend
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < habitNames.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: lineColors[i % lineColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          habitNames[i],
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class LineChartBox extends StatelessWidget {
  const LineChartBox({
    super.key,
    required this.habitNames,
    required this.habitProgression,
    required this.lineColors,
    required this.trendLabels,
    required this.maxTrendValue,
  });

  final List<String> habitNames;
  final Map<String, List<double>> habitProgression;
  final List<Color> lineColors;
  final trendLabels;
  final maxTrendValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                          color: Theme.of(context).colorScheme.onSecondary,
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
                          color: Theme.of(context).colorScheme.onSecondary,
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
            for (int i = 0; i < habitNames.length; i++)
              myLineChartBarData(
                spots: List.generate(
                  habitProgression[habitNames[i]]!.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    habitProgression[habitNames[i]]![index],
                  ),
                ),
                color: lineColors[i % lineColors.length],
                habitName: habitNames[i],
              ),
          ],
        ),
      ),
    );
  }
}

// ignore: strict_top_level_inference
LineChartBarData myLineChartBarData({
  required List<FlSpot> spots,
  required Color color,
  String? habitName,
}) {
  return LineChartBarData(
    show: true,
    spots: spots,
    isCurved: true,
    color: color,
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: true),
    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
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
      double value = (heatmapData[date] ?? 0) / 0.5;
      habitData[habitName]?.add(value);
    }
  }

  return habitData;
}
