import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/HabitStats_data.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildStatItem.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildStreakBadge.dart';

Widget BuildSummaryCard() {
  final Map<String, dynamic> stats = calculateStats();
  return Builder(
    builder: (context) {
      return Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(width: 5),
                    Center(
                      child: Text(
                        S.current.summary,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    BuildStreakBadge(stats['streak']),
                    // SizedBox(width: 5),s
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                
                children: [
                  BuildStatItem(
                    S.current.total,
                    stats['totalHabits'].toString(),
                    Icons.list_alt,
                    Colors.blue,
                  ),
                  BuildStatItem(
                    S.current.completed,
                    stats['completedHabits'].toString(),
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                  BuildStatItem(
                    S.current.success,
                    '${stats['completionRate'].toStringAsFixed(1)}%',
                    Icons.trending_up,
                    stats['completionRate'] > 50 ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
