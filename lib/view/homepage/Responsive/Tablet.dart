import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/models/MonthlySummary.dart';
import 'package:habit_tracker/view/homepage/widget/DrawerMenuButton.dart';
import 'package:habit_tracker/view/homepage/widget/ExpandedCheckboxList.dart';
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
                Expanded(flex: 4, child: const DrawerList()),

              if (!controller.isDesktop(context)) const DrawerMenuButton(),

              // Middle: Monthly Summary
              Expanded(
                flex: controller.isDesktop(context) ? 8 : 9,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ListView(
                    reverse: true,
                    key: ValueKey<String>(controller.getStartDay()),
                    scrollDirection: Axis.horizontal,
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
