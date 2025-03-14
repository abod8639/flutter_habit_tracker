import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/custom/MonthlySummary.dart';
import 'package:habit_tracker/custom/TextTaile.dart';
import 'package:habit_tracker/custom/myDrawer.dart';
import 'package:habit_tracker/custom/my_fab.dart';

class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  @override
  Widget build(BuildContext context) {
    Get.put(HabitController());
    return Scaffold(
      drawer: myDrawer(),
      // backgroundColor: Colors.grey[900],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            (controller) => ListView(
              // shrinkWrap: true,
              children: [
                //? Drawer Icon
                Builder(
                  builder: (context) {
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: Icon(Icons.drag_handle),
                        ),
                      ],
                    );
                  },
                ),
                //? MonthlySummaryList
                ListView( 
                  // scrollDirection: Axis.horizontal,
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  // scrollDirection: Axis.horizontal,
                  children: [
                    MonthlySummary(
                      datasets: controller.db.heatmapDateSet,
                      startDate: controller.get.toString(),
                    ),
                  ],
                ),
                //? TextTaile Habit list
                ListView.builder(
                  // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //   childAspectRatio: 2.5,
                  //   mainAxisSpacing: 2.5,
                  //   crossAxisCount: 2),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                      onDelete: (context) => controller.deleteHabit(index,context ),
                      onEdit:
                          (context) =>
                              controller.editHabit(index, context),
                      Habitname: controller.db.todaysHabitList[index][0],
                      HabitCombleted: controller.db.todaysHabitList[index][1],
                      onChanged: (value) {
                        controller.toggleHabit(value, index);
                        controller.db.updateData();
                      },
                    );
                  },
                ),
              ],
            ),
      ),
    );
  }
}
