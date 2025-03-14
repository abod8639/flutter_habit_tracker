import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/custom/MonthlySummary.dart';
import 'package:habit_tracker/custom/TextTaile.dart';
import 'package:habit_tracker/custom/myDrawer.dart';
import 'package:habit_tracker/custom/my_fab.dart';

class Tablet extends StatelessWidget {
  const Tablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: myDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: GetBuilder<HabitController>(
        init: HabitController(),
        builder:
            (controller) => myfloatingActionButton(
              onPressed: () => controller.addHabit(context),
            ),
      ),

      body: GetBuilder<HabitController>(
        init: HabitController(),
        builder:
            (controller) => Row(
              children: [
                // Left Side: Completed Habits List (Visible only on Desktop)
                if (controller.isDesktop(context))
                  Expanded(flex: 5, child: DrawerList()),

                if (!controller.isDesktop(context))
                  //? DrawerList
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Builder(
                        builder: (context) {
                          return Row(
                            children: [
                              IconButton(
                                onPressed:
                                    () => Scaffold.of(context).openDrawer(),
                                icon: Icon(Icons.drag_handle),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                // Middle: Monthly Summary
                //? MonthlySummary List
                Expanded(
                  flex: controller.isDesktop(context) ? 7 : 8,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: [
                      MonthlySummary(
                        datasets: controller.db.heatmapDateSet,
                        startDate: controller.get.toString(),
                      ),
                    ],
                  ),
                ),

                // GridExpadedChekboxList(),
                ExpadedChekboxList(),
              ],
            ),
      ),
    );
  }
}

class ExpadedChekboxList extends StatelessWidget {
  const ExpadedChekboxList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HabitController>(
      init: HabitController(),
      builder:
          (controller) => Expanded(
            flex: controller.isDesktop(context) ? 10 : 14,

            child: ListView.builder(
              // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //   childAspectRatio: 1,
              //   crossAxisSpacing: 0,
              //   mainAxisSpacing: 1,
              //   crossAxisCount: 2,
              //   mainAxisExtent: 100,
              //   ),
              physics:
                  controller.isPhone(context)
                      ? const NeverScrollableScrollPhysics()
                      : const ScrollPhysics(),
              itemCount: controller.db.todaysHabitList.length,
              itemBuilder: (context, index) {
                controller.index = index;

                return TextTaile(
                  onTap: () {
                    controller.toggleHabit(
                      (controller.db.todaysHabitList[index][1] == false),
                      index,
                    );
                    controller.db.updateData();
                  },
                  onDelete: (context) => controller.deleteHabit(index, context),
                  onEdit:
                      (context) =>
                          controller.editHabit(index, context),
                  Habitname: controller.db.todaysHabitList[index][0],
                  HabitCombleted: controller.db.todaysHabitList[index][1],
                  onChanged: (value) {
                    print(value);
                    controller.toggleHabit(value, index);
                    controller.db.updateData();
                  },
                );
              },
            ),
          ),
    );
  }
}

class GridExpadedChekboxList extends StatelessWidget {
  const GridExpadedChekboxList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HabitController>(
      init: HabitController(),
      builder:
          (controller) => Expanded(
            flex: controller.isDesktop(context) ? 10 : 14,

            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 1,
                crossAxisCount: 2,
                mainAxisExtent: 100,
              ),
              physics:
                  controller.isPhone(context)
                      ? const NeverScrollableScrollPhysics()
                      : const ScrollPhysics(),
              itemCount: controller.db.todaysHabitList.length,
              itemBuilder: (context, index) {
                controller.index = index;

                return TextTaile(
                  onTap: () {
                    controller.toggleHabit(
                      (controller.db.todaysHabitList[index][1] == false),
                      index,
                    );
                    controller.db.updateData();
                  },
                  onDelete: (context) => controller.deleteHabit(index, context),
                  onEdit:
                      (context) =>
                          controller.editHabit(index, context),
                  Habitname: controller.db.todaysHabitList[index][0],
                  HabitCombleted: controller.db.todaysHabitList[index][1],
                  onChanged: (value) {
                    print(value);
                    controller.toggleHabit(value, index);
                    controller.db.updateData();
                  },
                );
              },
            ),
          ),
    );
  }
}
