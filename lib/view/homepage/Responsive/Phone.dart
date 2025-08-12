import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';
import 'package:habit_tracker/functions/addHabit.dart';
import 'package:habit_tracker/view/homepage/widget/HabitList.dart';
import 'package:habit_tracker/view/homepage/widget/SliverMonthlySummary.dart';
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
      floatingActionButton: myfloatingActionButton(
        onPressed: () => addHabit(context),
      ),
      body: SafeArea(
        child: Obx(() {
          // Show loading indicator during initialization
          if (controller.isLoading.value) {
            return buildLoadingScreen();
          }

          // Show error message if initialization failed
          if (controller.errorMessage.value.isNotEmpty) {
            return buildErrorScreen();
          }

          return GetBuilder<HabitController>(
            builder: (controller) {
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // DrawerMenuButton(),
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
  }
}
