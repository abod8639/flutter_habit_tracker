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

class HabitStatsPage extends StatelessWidget {
  final HabitController habitController = Get.find<HabitController>();

  HabitStatsPage({super.key});

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
    double maxValue = 0;

    for (int i = 0; i < recentDates.length; i++) {
      final DateTime date = recentDates[i];
      final int value = heatmapData[date] ?? 0;
      final double percentage = value.toDouble();

      if (percentage > maxValue) {
        maxValue = percentage;
      }

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
    final int totalHabits = controller.db.todaysHabitList.length;
    final int completedHabits =
        controller.db.todaysHabitList.where((habit) => habit[1] == true).length;
    final double completionRate =
        totalHabits > 0 ? (completedHabits / totalHabits) * 100 : 0;

    return {
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'completionRate': completionRate,
    };
  }

  List<Map<String, dynamic>> _prepareChartData(HabitController controller) {
    return controller.db.todaysHabitList
        .map((habit) => {'habit': habit[0], 'completed': habit[1]})
        .toList();
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
          title: const Text('Habit Statistics'),
          centerTitle: true,
        ),
        body: GetBuilder<HabitController>(
          builder: (controller) {
            final stats = _calculateStats(controller);
            final chartData = _prepareChartData(controller);
            final trendSpots = _prepareTrendData();
            final trendLabels = _prepareTrendLabels();
            final maxTrendValue = _getMaxTrendValue();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BuildSummaryCard(stats),
                    SizedBox(height: 20),
                    _buildChartsSection(context, controller, stats, chartData),
                    SizedBox(height: 20),
                    if (stats['totalHabits'] > 0) SizedBox(height: 20),
                    BuildTrendChart(
                      context,
                      trendSpots,
                      trendLabels,
                      maxTrendValue,
                    ),
                    BuildHabitListCard(context, chartData),
                  ],
                ),
              ),
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
    // final stats = _calculateStats(controller);
    final chartData = _prepareChartData(controller);
    final trendSpots = _prepareTrendData();
    final trendLabels = _prepareTrendLabels();
    final maxTrendValue = _getMaxTrendValue();
    return controller.isDesktop(context)
        ? Row(
          children: [
            Expanded(child: BuildBarChart(context, chartData)),
            SizedBox(width: 10),
            Expanded(
              child: BuildTrendChart(
                context,
                trendSpots,
                trendLabels,
                maxTrendValue,
              ),
            ),
            SizedBox(width: 10),
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
            SizedBox(height: 16),
            // _buildPieChart(
            //   context,
            //   stats['completedHabits'],
            //   stats['totalHabits'],
            // ),
          ],
        );
  }

  //////////////////////////////////////////

  // New helper method to extract habit progression data
}
