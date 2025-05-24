import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/models/MonthlySummary.dart';
import 'package:habit_tracker/view/homepage/widget/HabitList.dart';
import 'package:habit_tracker/view/widget/buildErrorScreen.dart';
import 'package:habit_tracker/view/widget/buildLoadingScreen.dart';
import 'package:habit_tracker/view/widget/myDrawer.dart';
import 'package:habit_tracker/view/widget/my_fab.dart';

class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> with SingleTickerProviderStateMixin {
  final HabitController controller = Get.find<HabitController>();
  late final AnimationController _menuAnimationController;
  late final Animation<double> _menuRotationAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuRotationAnimation = Tween<double>(begin: 0, end: 1).animate(
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
      drawer: const myDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: myfloatingActionButton(
        onPressed: () => controller.addHabit(context),
      ),
      body: SafeArea(
        child: Obx(() {
          // Show loading indicator during initialization
          if (controller.isLoading.value) {
            return buildLoadingScreen();
          }

          // Show error message if initialization failed
          if (controller.errorMessage.value.isNotEmpty) {
            return buildErrorScreen(controller.errorMessage.value);
          }

          return GetBuilder<HabitController>(
            builder: (controller) {
              final habits = controller.db.todaysHabitList;
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  MyAppBar(),
                  SliverToBoxAdapter(
                    child: Center(
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: MonthlySummary(
                            datasets: controller.db.heatmapDateSet,
                            startDate: controller.getStartDay(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  HabitList(habits: habits),
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
          final state = context.findAncestorStateOfType<_PhoneState>();
          return AnimatedBuilder(
            animation: state!._menuRotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: state._menuRotationAnimation.value * 0.5,
                child: IconButton(
                  icon: Icon(
                    color: Theme.of(context).colorScheme.onSurface,
                    Icons.menu,
                  ),
                  onPressed: () {
                    state._menuAnimationController.forward().then((_) {
                      state._menuAnimationController.reverse();
                      Scaffold.of(context).openDrawer();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
