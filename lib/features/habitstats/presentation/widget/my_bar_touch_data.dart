import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';

BarTouchData myBarTouchData(BuildContext context) {
  final controller = Get.find<HabitStatsController>();

  return BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tooltipMargin: 8,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final List<Map<String, dynamic>> chartData = controller.todaySummary;
        if (groupIndex < 0 || groupIndex >= chartData.length) return null;

        final Map<String, dynamic> habit = chartData[groupIndex];
        final String name = habit['habit'] ?? 'Unnamed';
        final bool completed = habit['completed'] ?? false;

        return BarTooltipItem(
          name,
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text:
                  '\n${completed ? S.current.tooltipItemCompleted : S.current.tooltipItem}',
              style: TextStyle(
                color: completed
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 1.0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    ),
  );
}
