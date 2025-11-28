import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/HabitStats_data.dart';

BarTouchData MyBarTouchData(BuildContext context) {
  final List<Map<String, dynamic>> chartData = prepareChartData();

  return BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tooltipMargin: 8,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
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
                color:
                    completed
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error.withRed(255),
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
