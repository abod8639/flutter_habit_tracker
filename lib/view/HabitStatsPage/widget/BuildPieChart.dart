import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget BuildPieChart(
  BuildContext context,
  int completedHabits,
  int totalHabits,
) {
  if (totalHabits <= 0) {
    return SizedBox(
      height: 300,
      child: Center(child: Text('No habits to display')),
    );
  }

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 300,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                value: completedHabits.toDouble(),
                title: 'Completed',
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
                title: 'Incomplete',
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
