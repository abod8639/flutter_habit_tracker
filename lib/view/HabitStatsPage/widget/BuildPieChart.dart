import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/HabitStats_data.dart';

Widget BuildPieChart() {
  final Map<String, dynamic> stats = calculateStats();

  final int completedHabits = stats['completedHabits'];
  final int totalHabits = stats['totalHabits'];
  if (totalHabits <= 0) {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 330,
          child: Center(child: Text(S.current.pieChartIsEmpty)),
        );
      },
    );
  }

  return Builder(
    builder: (context) {
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
                    title: S.current.completedLabel,
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
                    title: S.current.incomplete,
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
    },
  );
}
