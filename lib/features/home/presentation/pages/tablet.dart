import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/functions/add_habit.dart';
import 'package:habit_tracker/features/home/presentation/widget/DrawerMenuButton.dart';
import 'package:habit_tracker/features/home/presentation/widget/ExpandedCheckboxList.dart';
import 'package:habit_tracker/features/home/presentation/widget/Nohabitsyet.dart';
import 'package:habit_tracker/core/components/monthly_summary.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/core/components/my_fab.dart';
import 'package:habit_tracker/utils/responsive_utils.dart';

class Tablet extends StatelessWidget {
  const Tablet({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return buildLoadingScreen();
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return buildErrorScreen();
      }

      return Scaffold(
        drawer: const MyDrawer(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: myfloatingActionButton(
          onPressed: () => addHabit(context),
        ),
        body: GetBuilder<HabitController>(
          init: controller,
          builder: (controller) => Stack(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade900,
                          Colors.blue.shade900,
                          Colors.teal.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Left Side: Completed Habits List (Visible only on Desktop)
                  if (ResponsiveUtils.isDesktop(context))
                    Expanded(flex: 4, child: const DrawerList()),

                  if (!ResponsiveUtils.isDesktop(context))
                    const DrawerMenuButton(),

                  // Middle: Monthly Summary
                  Expanded(
                    flex: ResponsiveUtils.isDesktop(context) ? 8 : 9,
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
                    flex: ResponsiveUtils.isDesktop(context) ? 9 : 13,
                    child: controller.db.todaysHabitList.isEmpty
                        ? Nohabitsyet()
                        : CheckboxList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
