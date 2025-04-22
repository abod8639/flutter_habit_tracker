import 'package:flutter/material.dart';

Widget BuildSummaryCard(Map<String, dynamic> stats) {
  return Card(
    elevation: 2.0,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Habits Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildStreakBadge(stats['streak']),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total',
                stats['totalHabits'].toString(),
                Icons.list_alt,
                Colors.blue,
              ),
              _buildStatItem(
                'Completed',
                stats['completedHabits'].toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
              _buildStatItem(
                'Success',
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
}

Widget _buildStatItem(String title, String value, IconData icon, Color color) {
  return Expanded(
    child: Builder(
      builder: (context) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: color,
              ),
            ),
          ],
        );
      },
    ),
  );
}

Widget _buildStreakBadge(int streak) {
  return Builder(
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withAlpha(40),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              'Day $streak',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      );
    },
  );
}
