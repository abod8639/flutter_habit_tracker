import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildBarChart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildHabitListCard.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildPieChart.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildSummaryCard.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildTreandChart.dart';

class HabitStatsPage extends StatefulWidget {
  const HabitStatsPage({super.key});

  @override
  State<HabitStatsPage> createState() => _HabitStatsPageState();
}

class _HabitStatsPageState extends State<HabitStatsPage>
    with SingleTickerProviderStateMixin {
  final HabitController habitController = Get.find<HabitController>();
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<FlSpot> _prepareTrendData() {
    final Map<DateTime, int> heatmapData = habitController.db.heatmapDateSet;
    if (heatmapData.isEmpty) {
      return [const FlSpot(0, 0)];
    }

    final List<DateTime> sortedDates =
        heatmapData.keys.toList()..sort((a, b) => a.compareTo(b));

    final int daysToShow = sortedDates.length > 10 ? 10 : sortedDates.length;
    final List<DateTime> recentDates = sortedDates.sublist(
      sortedDates.length - daysToShow,
    );

    List<FlSpot> trendSpots = [];

    for (int i = 0; i < recentDates.length; i++) {
      final DateTime date = recentDates[i];
      final int value = heatmapData[date] ?? 0;
      final double percentage = value.toDouble();
      trendSpots.add(FlSpot(i.toDouble(), percentage));
    }

    return trendSpots;
  }

  List<String> _prepareTrendLabels() {
    final Map<DateTime, int> heatmapData = habitController.db.heatmapDateSet;
    if (heatmapData.isEmpty) {
      return ['No data'];
    }

    final List<DateTime> sortedDates =
        heatmapData.keys.toList()..sort((a, b) => a.compareTo(b));

    final int daysToShow = sortedDates.length > 10 ? 10 : sortedDates.length;
    final List<DateTime> recentDates = sortedDates.sublist(
      sortedDates.length - daysToShow,
    );

    return recentDates.map((date) => '${date.day}/${date.month}').toList();
  }

  double _getMaxTrendValue() {
    final Map<DateTime, int> heatmapData = habitController.db.heatmapDateSet;
    if (heatmapData.isEmpty) return 70;

    double maxValue = 0;
    for (final value in heatmapData.values) {
      if (value > maxValue) {
        maxValue = value.toDouble();
      }
    }
    return maxValue + 20 > 100 ? 100 : maxValue + 20;
  }

  Map<String, dynamic> _calculateStats(HabitController controller) {
    // Use public methods to get habits data instead of accessing private fields
    final int totalHabits = controller.db.todaysHabitList.length;
    final int completedHabits = controller.db.getCompletedHabits().length;
    final double completionRate =
        totalHabits > 0 ? (completedHabits / totalHabits) * 100 : 0;

    return {
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'completionRate': completionRate,
      'streak': controller.dayCount.value,
    };
  }

  List<Map<String, dynamic>> _prepareChartData(HabitController controller) {
    // Use the public methods instead of directly accessing private fields
    final List<dynamic> habitsList = controller.db.todaysHabitList;

    return List.generate(habitsList.length, (index) {
      final habit = habitsList[index];
      return {
        'id': index.toString(),
        'habit': habit[0],
        'completed': habit[1],
        'createdAt': DateTime.now(),
      };
    });
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
            'Habit Statistics',
          ),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2.0,
        ),
        body: GetBuilder<HabitController>(
          builder: (controller) {
            final stats = _calculateStats(controller);
            final chartData = _prepareChartData(controller);
            final trendSpots = _prepareTrendData();
            final trendLabels = _prepareTrendLabels();
            final maxTrendValue = _getMaxTrendValue();

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
                        FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.0, 0.5),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.0,
                                  0.5,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: BuildSummaryCard(stats),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.2, 0.7),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.2,
                                  0.7,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: _buildChartsSection(
                              context,
                              controller,
                              stats,
                              chartData,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (stats['totalHabits'] > 0)
                          const SizedBox(height: 20),
                        FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.4, 0.9),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.4,
                                  0.9,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: BuildTrendChart(
                              context,
                              trendSpots,
                              trendLabels,
                              maxTrendValue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.6, 1.0),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.6,
                                  1.0,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: BuildHabitListCard(context, chartData),
                          ),
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

  Widget _buildChartsSection(
    BuildContext context,
    HabitController controller,
    Map<String, dynamic> stats,
    List<Map<String, dynamic>> chartData,
  ) {
    final trendSpots = _prepareTrendData();
    final trendLabels = _prepareTrendLabels();
    final maxTrendValue = _getMaxTrendValue();

    return controller.isDesktop(context)
        ? Row(
          children: [
            Expanded(child: BuildBarChart(context, chartData)),
            const SizedBox(width: 10),
            Expanded(
              child: BuildTrendChart(
                context,
                trendSpots,
                trendLabels,
                maxTrendValue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BuildPieChart(
                context,
                stats['completedHabits'],
                stats['totalHabits'],
              ),
            ),
          ],
        )
        : Column(
          children: [
            BuildBarChart(context, chartData),
            const SizedBox(height: 16),
            BuildPieChart(
              context,
              stats['completedHabits'],
              stats['totalHabits'],
            ),
          ],
        );
  }
}
