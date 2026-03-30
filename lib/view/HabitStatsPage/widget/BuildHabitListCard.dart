import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/HabitStats_data.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildHabitList.dart';

Widget BuildHabitListCard(BuildContext context) {
  final List<Map<String, dynamic>> chartData = prepareChartData();
  final completedHabits = chartData
      .where((habit) => habit['completed'] == true)
      .toList();
  final incompleteHabits = chartData
      .where((habit) => habit['completed'] == false)
      .toList();

  return Builder(
    builder: (context) {
      return Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.current.success,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (completedHabits.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${S.current.completedLabel} (${completedHabits.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BuildHabitList(context, completedHabits, true),
                const SizedBox(height: 16),
              ],

              if (incompleteHabits.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.pending_actions, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${S.current.incomplete} (${incompleteHabits.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BuildHabitList(context, incompleteHabits, false),
              ],

              if (chartData.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pending_actions,
                          size: 48,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          S.current.isEmpty,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
