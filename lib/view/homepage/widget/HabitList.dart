import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/view/widget/TextTaile.dart';

class HabitList extends StatelessWidget {
  const HabitList({super.key, required this.habits});

  final List<dynamic> habits;

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    if (habits.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_satisfied_alt,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No habits yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first habit with the + button',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: habits.length, (
        context,
        index,
      ) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutQuint,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: MyTextTaile(
            habitName: habits[index][0],
            habitCompleted: habits[index][1],
            onTap: () => controller.toggleHabit(!habits[index][1], index),
            onDelete: (context) => controller.deleteHabit(index, context),
            onEdit: (context) => controller.editHabit(index, context),
            onChanged: (value) => controller.toggleHabit(value, index),
          ),
        );
      }),
    );
  }
}
