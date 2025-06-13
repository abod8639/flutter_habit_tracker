import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/calculateOverallProgress.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/getHabitProgressionData.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/LineChartBox.dart';

final HabitController habitController = Get.put(HabitController());
// final myBox = Hive.box('Habit_db');

class TrendChartState extends GetxController {
  final RxBool showIndividualProgress = true.obs;
  void toggleView() => showIndividualProgress.toggle();
}

Widget BuildTrendChart({
  required List<FlSpot> trendSpots,
  required List<String> trendLabels,
  required double maxTrendValue,
}) {
  // final List<Map<String, dynamic>> chartData = prepareChartData();
  // final List<Map<String, dynamic>> chartData;
  final chartState = Get.put(TrendChartState());

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
  final Map<String, List<double>> habitProgression = getHabitProgressionData();
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).monthly,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => IconButton(
                        onPressed: chartState.toggleView,
                        icon: Icon(
                          chartState.showIndividualProgress.value
                              ? Icons.stacked_line_chart
                              : Icons.view_list,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        // label: Text(
                        //   chartState.showIndividualProgress.value
                        //       ? 'Overall Progress'
                        //       : 'Individual Progress',
                        //   style: TextStyle(
                        //     color: Theme.of(context).colorScheme.primary,
                        //   ),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => LineChartBox(
                  maxTrendValue: 1.0,
                  trendLabels: trendLabels,
                  habitNames:
                      chartState.showIndividualProgress.value
                          ? habitNames
                          : ['Overall'],
                  habitProgression:
                      chartState.showIndividualProgress.value
                          ? habitProgression
                          : {
                            'Overall': calculateOverallProgress(
                              habitProgression,
                            ),
                          },
                  lineColors: lineColors,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (!chartState.showIndividualProgress.value) {
                  return const SizedBox.shrink();
                }
                return Wrap(
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
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
