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
    _menuRotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_menuAnimationController);
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
        child: GetBuilder<HabitController>(
          builder: (controller) {
            final habits = controller.db.todaysHabitList;
            return CustomScrollView(
              // shrinkWrap: true,
              controller: _scrollController,
              slivers: [
                _appBar(),

                SliverToBoxAdapter(
                  child: Center(
                    child: SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      child: MonthlySummary(
                        datasets: controller.db.heatmapDateSet,
                        startDate: controller.getStartDay(),
                      ),
                    ),
                  ),
                ),

                _chikList(habits: habits),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _appBar extends StatelessWidget {
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

class _chikList extends StatelessWidget {
  const _chikList({required this.habits});

  final List<dynamic> habits;

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

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
