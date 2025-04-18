import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/models/MonthlySummary.dart';
import 'package:habit_tracker/view/widget/TextTaile.dart';
import 'package:habit_tracker/view/widget/myDrawer.dart';
import 'package:habit_tracker/view/widget/my_fab.dart';

class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> with SingleTickerProviderStateMixin {
  final HabitController _controller = Get.find<HabitController>();
  late AnimationController _menuAnimationController;
  late Animation<double> _menuRotationAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuRotationAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _menuAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _menuAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: myDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: myfloatingActionButton(
        onPressed: () => _controller.addHabit(context),
      ),
      body: GetBuilder<HabitController>(
        builder:
            (controller) => Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: MonthlySummary(
                          datasets: controller.db.heatmapDateSet,
                          startDate: controller.getStartDay(),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        controller.index.value = index;
                        // Add staggered animation to list items
                        return AnimatedBuilder(
                          animation: _scrollController,
                          builder: (context, child) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 300 + (index * 50),
                              ),
                              curve: Curves.easeOutQuint,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: TextTaile(
                                onTap: () {
                                  controller.toggleHabit(
                                    (controller.db.todaysHabitList[index][1] ==
                                        false),
                                    index,
                                  );
                                  controller.db.updateData();
                                },
                                onDelete:
                                    (context) =>
                                        controller.deleteHabit(index, context),
                                onEdit:
                                    (context) =>
                                        controller.editHabit(index, context),
                                habitName:
                                    controller.db.todaysHabitList[index][0],
                                habitCompleted:
                                    controller.db.todaysHabitList[index][1],
                                onChanged: (value) {
                                  controller.toggleHabit(value, index);
                                  controller.db.updateData();
                                },
                              ),
                            );
                          },
                        );
                      }, childCount: controller.db.todaysHabitList.length),
                    ),
                  ],
                ),
                SafeArea(
                  child: Positioned(
                    top: 5,
                    left: 5,
                    child: Builder(
                      builder: (context) {
                        return AnimatedBuilder(
                          animation: _menuAnimationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _menuRotationAnimation.value * 2 * 3.14159,
                              child: IconButton(
                                onPressed: () {
                                  _menuAnimationController.forward().then((_) {
                                    _menuAnimationController.reverse();
                                    Scaffold.of(context).openDrawer();
                                  });
                                },
                                icon: const Icon(Icons.drag_handle),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
