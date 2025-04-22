import 'package:flutter/material.dart';

Widget BuildHabitListCard(
  BuildContext context,
  List<Map<String, dynamic>> chartData,
) {
  final completedHabits =
      chartData.where((habit) => habit['completed'] == true).toList();
  final incompleteHabits =
      chartData.where((habit) => habit['completed'] == false).toList();

  return Card(
    elevation: 2.0,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habit Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (completedHabits.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Completed (${completedHabits.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildHabitList(context, completedHabits, true),
            const SizedBox(height: 16),
          ],

          if (incompleteHabits.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Pending (${incompleteHabits.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildHabitList(context, incompleteHabits, false),
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
                    const Text(
                      'No habits tracked yet',
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
}

Widget _buildHabitList(
  BuildContext context,
  List<Map<String, dynamic>> habits,
  bool isCompleted,
) {
  return Container(
    decoration: BoxDecoration(
      color:
          isCompleted
              ? Colors.green.withOpacity(0.05)
              : Colors.orange.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: habits.length,
      separatorBuilder:
          (context, index) =>
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
      itemBuilder: (context, index) {
        final habit = habits[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: CircleAvatar(
            backgroundColor: isCompleted ? Colors.green : Colors.orange,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            habit['habit'],
            style: TextStyle(
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.orange,
          ),
        );
      },
    ),
  );
}
