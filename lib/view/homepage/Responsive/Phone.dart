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
            return _buildLoadingScreen();
          }

          // Show error message if initialization failed
          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorScreen(controller.errorMessage.value);
          }

          return GetBuilder<HabitController>(
            builder: (controller) {
              final habits = controller.db.todaysHabitList;
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _AppBar(),
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
                  _HabitList(habits: habits),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your habits...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Just a moment',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Recreate the controller to reinitialize
                Get.delete<HabitController>();
                Get.put(HabitController());
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
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
      // actions: [
      //   IconButton(
      //     icon: Icon(
      //       Icons.nightlight_round,
      //       color: Theme.of(context).colorScheme.onSurface,
      //     ),
      //     onPressed:
      //         () => Get.changeThemeMode(
      //           Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
      //         ),
      //   ),
      // ],
    );
  }
}

class _HabitList extends StatelessWidget {
  const _HabitList({required this.habits});

  final List<dynamic> habits;

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    if (habits.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_satisfied_alt,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No habits yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first habit with the + button',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: habits.length, (
        context,
        index,
      ) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutQuint,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: MyTextTaile(
            habitName: habits[index][0],
            habitCompleted: habits[index][1],
            onTap: () => controller.toggleHabit(!habits[index][1], index),
            onDelete: (context) => controller.deleteHabit(index, context),
            onEdit: (context) => controller.editHabit(index, context),
            onChanged: (value) => controller.toggleHabit(value, index),
          ),
        );
      }),
    );
  }
}
