import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/functions/deleteHabit.dart';
import 'package:habit_tracker/functions/editHabit.dart';
import 'package:habit_tracker/functions/toggleHabit.dart';
import 'package:habit_tracker/view/widget/TextTaile.dart';

class ExpandedCheckboxList extends StatelessWidget {
  const ExpandedCheckboxList({super.key, required this.habits});

  final List<dynamic> habits;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HabitController>(
      builder:
          (controller) => Expanded(
            flex: controller.isDesktop(context) ? 9 : 13,
            child: Padding(
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
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: MyTextTaile(
                        onTap: () => toggleHabit(!habits[index][1], index),

                        onDelete: (context) => deleteHabit(index, context),
                        onEdit: (context) => editHabit(index, context),
                        habitName: habits[index][0],
                        habitCompleted: habits[index][1],
                        onChanged: (value) => toggleHabit(value, index),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }
}
