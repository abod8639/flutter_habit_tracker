import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/functions/add_habit.dart';
import 'package:habit_tracker/core/components/habit_list.dart';
import 'package:habit_tracker/features/home/presentation/widget/SliverMonthlySummary.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/core/components/my_fab.dart';

class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> with SingleTickerProviderStateMixin {
  final HabitController controller = Get.put(HabitController());
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(
        () => controller.isSelectionMode
            ? const SizedBox.shrink()
            : myfloatingActionButton(
                onPressed: () => addHabit(context),
              ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return buildLoadingScreen();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return buildErrorScreen();
          }

          return GetBuilder<HabitController>(
            builder: (controller) {
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  MyAppBar(),
                  SliverMonthlySummary(),
                  HabitList(),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    return Obx(() {
      if (controller.isSelectionMode) {
        return SliverAppBar(
          pinned: true,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => controller.clearSelection(),
          ),
          title: Text(
            '${controller.selectedHabitIds.length} Selected',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.color_lens, color: Colors.white),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Choose Color'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children:
                            [
                                  Colors.red,
                                  Colors.pink,
                                  Colors.purple,
                                  Colors.deepPurple,
                                  Colors.indigo,
                                  Colors.blue,
                                  Colors.lightBlue,
                                  Colors.cyan,
                                  Colors.teal,
                                  Colors.green,
                                  Colors.lightGreen,
                                  Colors.lime,
                                  Colors.yellow,
                                  Colors.amber,
                                  Colors.orange,
                                  Colors.deepOrange,
                                  Colors.brown,
                                  Colors.grey,
                                  Colors.blueGrey,
                                  Colors.black,
                                ]
                                .map(
                                  (color) => InkWell(
                                    onTap: () {
                                      controller.updateSelectedHabitsColor(
                                        color,
                                      );
                                      Get.back();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _showBatchDeleteConfirm(context, controller),
            ),
          ],
        );
      }

      return SliverAppBar(
        pinned: true,
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        floating: true,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                color: Theme.of(context).colorScheme.onSurface,
                Icons.menu,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      );
    });
  }

  void _showBatchDeleteConfirm(
    BuildContext context,
    HabitController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected'),
        content: Text(
          'Are you sure you want to delete ${controller.selectedHabitIds.length} habits?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteSelectedHabits();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
