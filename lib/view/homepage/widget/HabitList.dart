import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/functions/deleteHabit.dart';
import 'package:habit_tracker/functions/editHabit.dart';
import 'package:habit_tracker/functions/toggleHabit.dart';
import 'package:habit_tracker/view/homepage/widget/Nohabitsyet.dart';
import 'package:habit_tracker/view/widget/TextTaile.dart';

class HabitList extends StatelessWidget {
  const HabitList({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    final List habits = controller.db.todaysHabitList;

    if (habits.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: Nohabitsyet());
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
            habitName: habits[index].name,
            habitCompleted: habits[index].isCompleted,
            onTap: () => toggleHabit(!habits[index].isCompleted, index),
            onDelete: (context) => deleteHabit(index, context),
            onEdit: (context) => editHabit(index, context),
            onChanged: (value) => toggleHabit(value, index),
          ),
        );
      }),
    );
  }
}
