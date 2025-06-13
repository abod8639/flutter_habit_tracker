import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/HabitStats_data.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/FadeAnimateonSummaryCard.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/FadeAnimationChartsSection.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/FadeAnimationTrendChart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/FaedAnimationHabitListCard.dart';

class HabitStatsPage extends StatefulWidget {
  const HabitStatsPage({super.key});

  @override
  State<HabitStatsPage> createState() => _HabitStatsPageState();
}

class _HabitStatsPageState extends State<HabitStatsPage>
    with SingleTickerProviderStateMixin {
  final HabitController habitController = Get.put(HabitController());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        // Skip handling special keys like NumLock to avoid conflicts
        if (event.physicalKey == PhysicalKeyboardKey.numLock) {
          return;
        }

        if (event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.backspace) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            color: Theme.of(context).colorScheme.onSurface,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            S.of(context).ratepagetitle,
          ),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2.0,
        ),
        body: GetBuilder<HabitController>(
          init: HabitController(),
          builder: (controller) {
            final stats = calculateStats();
            // final chartData = prepareChartData();
            // final trendSpots = prepareTrendData();
            // final trendLabels = prepareTrendLabels();
            // final maxTrendValue = getMaxTrendValue();

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeAnimateonSummaryCard(
                          animationController: _animationController,
                        ),

                        const SizedBox(height: 20),

                        FadeAnimationChartsSection(
                          animationController: _animationController,
                        ),

                        const SizedBox(height: 20),

                        if (stats['totalHabits'] > 0)
                          const SizedBox(height: 20),

                        FadeAnimationTrendChart(
                          animationController: _animationController,
                        ),

                        const SizedBox(height: 20),

                        FaedAnimationHabitListCard(
                          animationController: _animationController,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
