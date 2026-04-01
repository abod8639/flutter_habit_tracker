import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'build_habit_list.dart';

Widget buildHabitListCard(BuildContext context) {
  final HabitStatsController controller = Get.find<HabitStatsController>();

  return Obx(() {
    final List<Map<String, dynamic>> chartData = controller.todaySummary;
    final completedHabits = chartData
        .where((habit) => habit['completed'] == true)
        .toList();
    final incompleteHabits = chartData
        .where((habit) => habit['completed'] == false)
        .toList();

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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (completedHabits.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
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
              buildHabitList(context, completedHabits, true),
              const SizedBox(height: 16),
            ],

            if (incompleteHabits.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.pending_actions,
                    color: Colors.orange,
                    size: 18,
                  ),
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
              buildHabitList(context, incompleteHabits, false),
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
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.current.isEmpty,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  });
}
