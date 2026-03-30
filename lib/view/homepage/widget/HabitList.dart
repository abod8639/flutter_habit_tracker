import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/functions/delete_habit.dart';
import 'package:habit_tracker/functions/edit_habit.dart';
import 'package:habit_tracker/functions/toggle_habit.dart';
import 'package:habit_tracker/view/homepage/widget/Nohabitsyet.dart';
import 'package:habit_tracker/view/widget/TextTaile.dart';

class HabitList extends StatelessWidget {
  const HabitList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HabitController>(
      builder: (controller) {
        final List habits = controller.db.todaysHabitList;

        if (habits.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Nohabitsyet(),
          );
        }

        return SliverReorderableList(
          itemCount: habits.length,
          onReorder: (oldIndex, newIndex) =>
              controller.reorderHabits(oldIndex, newIndex),
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final double elevation =
                    Curves.easeInOut.transform(animation.value) * 10;
                final double scale =
                    1.0 + (Curves.easeInOut.transform(animation.value) * 0.05);
                return Material(
                  elevation: elevation,
                  borderRadius: BorderRadius.circular(10),
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  color: Colors.transparent,
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: child,
            );
          },
          itemBuilder: (context, index) {
            return ReorderableDelayedDragStartListener(
              index: index,
              key: ValueKey(habits[index].id),
              child: TweenAnimationBuilder<double>(
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
                  isSelected: controller.selectedHabitIds.contains(habits[index].id),
                  isSelectionMode: controller.isSelectionMode,
                  onTap: () => toggleHabit(!habits[index].isCompleted, index),
                  onDelete: (context) => deleteHabit(index, context),
                  onEdit: (context) => editHabit(index, context),
                  onChanged: (value) => toggleHabit(value, index),
                  onLongPress: () => controller.toggleHabitSelection(habits[index].id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
