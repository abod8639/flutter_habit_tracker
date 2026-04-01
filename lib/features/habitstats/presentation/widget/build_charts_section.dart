import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_bar_chart.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_pie_chart.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_trend_chart.dart';
import 'package:habit_tracker/utils/responsive_utils.dart';

Widget buildChartsSection(BuildContext context) {
  return GetBuilder<HabitController>(
    builder: (controller) {
      return ResponsiveUtils.isDesktop(context)
          ? Row(
              children: [
                Expanded(child: buildBarChart()),
                const SizedBox(width: 10),
                Expanded(child: buildTrendChart()),
                const SizedBox(width: 10),
                Expanded(child: buildPieChart()),
              ],
            )
          : Column(
              children: [
                buildBarChart(),
                const SizedBox(height: 16),
                buildPieChart(),
              ],
            );
    },
  );
}
