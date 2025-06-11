import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/HabitStats_data.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildBarChart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildPieChart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildTreandChart.dart';

Widget buildChartsSection(
  BuildContext context,
  Map<String, dynamic> stats,
  List<Map<String, dynamic>> chartData,
) {
  final trendSpots = prepareTrendData();
  final trendLabels = prepareTrendLabels();
  final maxTrendValue = getMaxTrendValue();

  return GetBuilder<HabitController>(
    builder: (controller) {
      return controller.isDesktop(context)
          ? Row(
            children: [
              Expanded(child: BuildBarChart(context, chartData)),
              const SizedBox(width: 10),
              Expanded(
                child: BuildTrendChart(
                  trendSpots: trendSpots,
                  trendLabels: trendLabels,
                  maxTrendValue: maxTrendValue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BuildPieChart(
                  context,
                  stats['completedHabits'],
                  stats['totalHabits'],
                ),
              ),
            ],
          )
          : Column(
            children: [
              BuildBarChart(context, chartData),
              const SizedBox(height: 16),
              BuildPieChart(
                context,
                stats['completedHabits'],
                stats['totalHabits'],
              ),
            ],
          );
    },
  );
}
