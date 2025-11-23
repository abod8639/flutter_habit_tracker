import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';
import 'package:habit_tracker/functions/deleteHabit.dart';
import 'package:habit_tracker/functions/editHabit.dart';
import 'package:habit_tracker/functions/toggleHabit.dart';
import 'package:habit_tracker/view/widget/TextTaile.dart';

class CheckboxList extends StatelessWidget {
  const CheckboxList({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.put(HabitController());

    final List habits = controller.db.todaysHabitList;
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: SizedBox(
        height: double.infinity,
        child: AnimatedList(
          scrollDirection: Axis.vertical,
          initialItemCount: controller.db.todaysHabitList.length,
          itemBuilder: (context, index, animation) {
            controller.index.value = index;

            if (index >= controller.db.todaysHabitList.length) {
              return const SizedBox.shrink();
            }

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: MyTextTaile(
                habitName: habits[index].name,
                habitCompleted: habits[index].isCompleted,
                onTap: () => toggleHabit(!habits[index].isCompleted, index),
                onDelete: (context) => deleteHabit(index, context),
                onEdit: (context) => editHabit(index, context),
                onChanged: (value) => toggleHabit(value, index),
              ),
            );
          },
        ),
      ),
    );
  }
}
