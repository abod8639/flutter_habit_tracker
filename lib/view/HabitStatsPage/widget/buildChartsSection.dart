import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildBarChart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildPieChart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/temp_file.dart';

Widget buildChartsSection(BuildContext context) {
  return GetBuilder<HabitController>(
    builder: (controller) {
      return controller.isDesktop(context)
          ? Row(
            children: [
              Expanded(child: BuildBarChart()),
              const SizedBox(width: 10),
              Expanded(child: BuildTrendChart()),
              const SizedBox(width: 10),
              Expanded(child: BuildPieChart()),
            ],
          )
          : Column(
            children: [
              BuildBarChart(),
              const SizedBox(height: 16),
              BuildPieChart(),
            ],
          );
    },
  );
}
