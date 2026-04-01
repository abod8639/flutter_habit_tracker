import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/functions/delete_habit.dart';
import 'package:habit_tracker/functions/edit_habit.dart';
import 'package:habit_tracker/functions/toggle_habit.dart';
import 'package:habit_tracker/features/home/presentation/widget/Nohabitsyet.dart';
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
          itemBuilder: (context, index) {
            final habit = habits[index];
            return ReorderableDelayedDragStartListener(
              key: ValueKey(habit.id),
              index: index,
              enabled: controller.isSelectionMode,
              child: MyTextTaile(
                habitName: habit.name,
                habitCompleted: habit.isCompleted,
                isSelected: controller.selectedHabitIds.contains(habit.id),
                isSelectionMode: controller.isSelectionMode,
                colorValue: habit.colorValue,
                onTap: () => toggleHabit(!habit.isCompleted, index),
                onDelete: (context) => deleteHabit(index, context),
                onEdit: (context) => editHabit(index, context),
                onChanged: (value) => toggleHabit(value, index),
                onLongPress: () => controller.toggleHabitSelection(habit.id),
              ),
            );
          },
        );
      },
    );
  }
}
