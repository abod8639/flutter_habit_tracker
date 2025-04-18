import 'package:flutter/material.dart';

Widget BuildSummaryCard(Map<String, dynamic> stats) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Habits Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', stats['totalHabits'].toString()),
              _buildStatItem('Completed', stats['completedHabits'].toString()),
              _buildStatItem(
                'Rate',
                '${stats['completionRate'].toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatItem(String title, String value) {
  return Expanded(
    child: Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    ),
  );
}
