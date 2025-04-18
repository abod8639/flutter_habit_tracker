import 'package:flutter/material.dart';

Widget BuildHabitListCard(
  BuildContext context,
  List<Map<String, dynamic>> chartData,
) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Completed Habits',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: chartData.length > 5 ? 300 : null,
            child: ListView.builder(
              physics:
                  chartData.length > 5
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: chartData.length,
              itemBuilder: (context, index) {
                final habit = chartData[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        habit['completed']
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.error,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: Text(habit['habit']),
                  trailing: Icon(
                    habit['completed'] ? Icons.check_circle : Icons.cancel,
                    color:
                        habit['completed']
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.error,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
