import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/controller/trend_chart_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/HabitStats_data.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/LineChartBox.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/WarpHabitNames.dart';

final HabitController habitController = Get.put(HabitController());
// final myBox = Hive.box('Habit_db');

final List<Color> lineColors = [
  // Theme.of(context).primaryColor,
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

Widget BuildTrendChart() {
  final chartState = Get.put(TrendChartState());
  final List<FlSpot> trendSpots = prepareTrendData(chartState.daysPeriod.value);
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
                  S.current.trendChartIsEmpty,
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

  return Builder(
    builder: (context) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          chartState.togglePeriod();
                        },
                        child: Text(
                          chartState.isWeeklyView.value
                              ? S.current.weekly
                              : S.current.monthly,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => chartState.toggleShowAllHabits(),
                        icon: Icon(
                          chartState.showAllHabits.value
                              ? Icons.stacked_line_chart
                              : Icons.view_list,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              LineChartBox(),

              const SizedBox(height: 16),

              WarpHabitNames(),
            ],
          ),
        ),
      );
    },
  );
}
