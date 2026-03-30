import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/build_bar_chart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildPieChart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildTrendChart.dart';
import 'package:habit_tracker/utils/responsive_utils.dart';

Widget buildChartsSection(BuildContext context) {
  return GetBuilder<HabitController>(
    builder: (controller) {
      return ResponsiveUtils.isDesktop(context)
          ? Row(
              children: [
                Expanded(child: buildBarChart()),
                const SizedBox(width: 10),
                Expanded(child: BuildTrendChart()),
                const SizedBox(width: 10),
                Expanded(child: BuildPieChart()),
              ],
            )
          : Column(
              children: [
                buildBarChart(),
                const SizedBox(height: 16),
                BuildPieChart(),
              ],
            );
    },
  );
}
