import 'package:flutter/material.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/getHabitProgressionData.dart';

class WarpHabitNames extends StatelessWidget {
  const WarpHabitNames({
    super.key,
    // required this.habitNames,
    required this.lineColors,
  });

  // final List<String> habitNames;
  final List<Color> lineColors;

  @override
  Widget build(BuildContext context) {
    final List<String> habitNames = getHabitProgressionData().keys.toList();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (int i = 0; i < habitNames.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: lineColors[i % lineColors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                habitNames[i],
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
