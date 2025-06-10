import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

Widget BuildPieChart(
  BuildContext context,
  int completedHabits,
  int totalHabits,
) {
  if (totalHabits <= 0) {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 330,
          child: Center(child: Text(S.of(context).PieChartisEmpty)),
        );
      },
    );
  }

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 350,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                value: completedHabits.toDouble(),
                title: S.of(context).Completed,
                color: Theme.of(context).primaryColor,
                radius: 100,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                value: (totalHabits - completedHabits).toDouble(),
                title: S.of(context).Incomplete,
                color: Theme.of(context).colorScheme.error,
                radius: 100,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
