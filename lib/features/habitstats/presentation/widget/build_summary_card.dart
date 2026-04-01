import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'build_stat_item.dart';
import 'build_streak_badge.dart';

Widget buildSummaryCard() {
  final HabitStatsController controller = Get.find<HabitStatsController>();

  return Obx(() {
    final stats = controller.stats.value;
    if (stats == null) return const SizedBox.shrink();

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
                  Center(
                    child: Text(
                      S.current.summary,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  buildStreakBadge(stats.streak),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildStatItem(
                  S.current.total,
                  stats.totalHabits.toString(),
                  Icons.list_alt,
                  Colors.blue,
                ),
                buildStatItem(
                  S.current.completed,
                  stats.completedHabits.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                buildStatItem(
                  S.current.success,
                  '${stats.completionRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  stats.completionRate > 50 ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  });
}
