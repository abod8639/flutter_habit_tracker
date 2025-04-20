import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/models/MonthlySummary.dart';
import 'package:habit_tracker/view/widget/TextTaile.dart';
import 'package:habit_tracker/view/widget/myDrawer.dart';
import 'package:habit_tracker/view/widget/my_fab.dart';

class Tablet extends StatefulWidget {
  const Tablet({super.key});

  @override
  State<Tablet> createState() => _TabletState();
}

class _TabletState extends State<Tablet> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HabitController>(
      init: HabitController(),
      builder: (controller) {
        final habits = controller.db.todaysHabitList;

        return Scaffold(
          drawer: const myDrawer(),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: myfloatingActionButton(
            onPressed: () => controller.addHabit(context),
          ),
          body: Row(
            children: [
              // Left Side: Completed Habits List (Visible only on Desktop)
              if (controller.isDesktop(context))
                Expanded(flex: 5, child: const DrawerList()),

              if (!controller.isDesktop(context)) const DrawerMenuButton(),

              // Middle: Monthly Summary
              Expanded(
                flex: controller.isDesktop(context) ? 7 : 8,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ListView(
                    key: ValueKey<String>(controller.getStartDay()),
                    scrollDirection: Axis.vertical,
                    children: [
                      MonthlySummary(
                        datasets: controller.db.heatmapDateSet,
                        startDate: controller.getStartDay(),
                      ),
                    ],
                  ),
                ),
              ),

              // Right Side: Habit Checklist
              ExpandedCheckboxList(habits: habits),
            ],
          ),
        );
      },
    );
  }
}

class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Builder(
          builder: (context) {
            return Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.drag_handle),
                    tooltip: 'Open menu',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ExpandedCheckboxList extends StatelessWidget {
  const ExpandedCheckboxList({super.key, required this.habits});

  final List<dynamic> habits;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HabitController>(
      builder:
          (controller) => Expanded(
            flex: controller.isDesktop(context) ? 10 : 14,
            child: AnimatedList(
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
                    onTap: () {
                      controller.toggleHabit(!habits[index][1], index);
                      controller.db.updateData();
                    },
                    onDelete:
                        (context) => controller.deleteHabit(index, context),
                    onEdit: (context) => controller.editHabit(index, context),
                    habitName: habits[index][0],
                    habitCompleted: habits[index][1],
                    onChanged: (value) {
                      controller.toggleHabit(value, index);
                      controller.db.updateData();
                    },
                  ),
                );
              },
            ),
          ),
    );
  }
}
