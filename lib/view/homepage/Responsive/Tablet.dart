import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/functions/addHabit.dart';
import 'package:habit_tracker/view/homepage/widget/DrawerMenuButton.dart';
import 'package:habit_tracker/view/homepage/widget/ExpandedCheckboxList.dart';
import 'package:habit_tracker/view/widget/MonthlySummary.dart';
import 'package:habit_tracker/view/widget/buildErrorScreen.dart';
import 'package:habit_tracker/view/widget/buildLoadingScreen.dart';
import 'package:habit_tracker/view/widget/myDrawer.dart';
import 'package:habit_tracker/view/widget/my_fab.dart';

class Tablet extends StatelessWidget {
  const Tablet({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.put(HabitController());
    return Obx(() {
      if (controller.isLoading.value) {
        return buildLoadingScreen();
      }

      // Show error message if initialization failed
      if (controller.errorMessage.value.isNotEmpty) {
        return buildErrorScreen(controller.errorMessage.value);
      }
      return Scaffold(
        drawer: const myDrawer(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: myfloatingActionButton(
          onPressed: () => addHabit(context),
        ),
        body: GetBuilder<HabitController>(
          init: controller,
          builder:
              (controller) => Row(
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
                      child: SingleChildScrollView(
                        reverse: true,
                        key: ValueKey<String>(controller.getStartDay()),
                        scrollDirection: Axis.horizontal,
                        child: MonthlySummary(
                          datasets: controller.db.heatmapDateSet,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: controller.isDesktop(context) ? 9 : 13,
                    child: CheckboxList(),
                  ),
                ],
              ),
        ),
      );
    });
  }
}
