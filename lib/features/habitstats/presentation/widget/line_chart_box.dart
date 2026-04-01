import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habitstats_controller.dart';
import 'my_line_chart_bar_data.dart';
import 'build_trend_chart.dart';

class LineChartBox extends StatelessWidget {
  const LineChartBox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitStatsController>();

    return SizedBox(
      height: 300,
      child: Obx(() {
        final Map<String, List<FlSpot>> progression =
            controller.individualTrends;

        // Generate labels based on period
        final now = DateTime.now();
        final List<String> trendLabels = List.generate(
          controller.daysPeriod.value,
          (index) {
            final date = now.subtract(
              Duration(days: controller.daysPeriod.value - 1 - index),
            );
            return '${date.day}/${date.month}';
          },
        );

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withValues(alpha: 0.05),
                  strokeWidth: 1,
                );
              },
            ),

            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < trendLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          trendLabels[index],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 25,
                  interval: controller.isWeeklyView.value ? 1 : 5,
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.25,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '${(value * 100).toInt()}%'
                            .replaceAll("110%", "")
                            .replaceAll("114%", "")
                            .replaceAll("-10%", ""),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                  reservedSize: 45,
                ),
              ),

              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),

            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),

            clipData: const FlClipData.all(),
            minX: 0.10,
            maxX: (trendLabels.length - 1).toDouble(),
            minY: -0.10,
            maxY: 1.15,

            lineBarsData: _buildLineBarsData(
              context: context,
              controller: controller,
              progression: progression,
              trendLabels: trendLabels,
            ),
          ),
        );
      }),
    );
  }

  List<LineChartBarData> _buildLineBarsData({
    required BuildContext context,
    required HabitStatsController controller,
    required Map<String, List<FlSpot>> progression,
    required List<String> trendLabels,
  }) {
    final List<LineChartBarData> lineBars = [];

    if (controller.showAllHabits.value) {
      lineBars.add(
        myLineChartBarData(
          color: Theme.of(context).primaryColor,
          spots: controller.overallTrend,
          label: 'Overall',
        ),
      );
    } else {
      for (int i = 0; i < controller.habitNames.length; i++) {
        final habitName = controller.habitNames[i];

        if (progression.containsKey(habitName)) {
          final spots = progression[habitName];
          if (spots != null && spots.isNotEmpty) {
            lineBars.add(
              myLineChartBarData(
                spots: spots,
                color: _getHabitColor(i, context),
                label: _getHabitLabel(habitName, controller.isWeeklyView.value),
              ),
            );
          }
        }
      }
    }

    return lineBars;
  }

  Color _getHabitColor(int index, BuildContext context) {
    if (index < lineColors.length) {
      return lineColors[index];
    }

    final fallbackColors = [
      Theme.of(context).primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];

    return fallbackColors[index % fallbackColors.length];
  }

  String _getHabitLabel(String habitName, bool isWeekly) {
    final period = isWeekly ? '7d' : '30d';
    return '$habitName ($period)';
  }
}
