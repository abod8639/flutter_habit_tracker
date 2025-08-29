import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/TrendChartState.Getx.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/HabitStats_data.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/getHabitProgressionData.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/prepareTodayHabitTrends.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/myLineChartBarData.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/temp_file.dart';

class LineChartBox extends StatelessWidget {
  const LineChartBox({super.key});

  @override
  Widget build(BuildContext context) {
    final chartState = Get.put(TrendChartState());

    final Map<String, List<FlSpot>> progression = prepareTodayHabitTrends(
      chartState.value.value,
    );

    final last7DaysHabits = getLast7DaysHabitProgression().keys.toList();
    final last30DaysHabits = getLast30DaysHabitProgression().keys.toList();
    final bool isWeekly = chartState.isweekly.value;
    final bool showIndividual = chartState.showIndividualProgress.value;

    final List<String> habitNames =
        showIndividual
            ? (isWeekly ? last7DaysHabits : last30DaysHabits)
            : ['Overall'];

    return SizedBox(
      height: 300,
      child: Obx(() {
        final List<String> trendLabels = prepareTrendLabels(
          chartState.value.value,
        );
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  // dashArray: const [5, 5],
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                // drawBelowEverything: false,
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index <= trendLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          trendLabels[index],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const Text('error');
                  },
                  reservedSize: 20,
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

            clipData: FlClipData.vertical(),
            baselineX: 10,
            minX: 0.10,
            maxX: trendLabels.length - 1.0,
            minY: -.10,
            maxY: 1.15,
            lineBarsData: [
              if (chartState.showIndividualProgress == true)
                myLineChartBarData(
                  color: Theme.of(context).primaryColor,
                  spots: prepareTrendData(chartState.value.value),
                  label: 'Overall',
                ),

              if (chartState.showIndividualProgress == false)
                for (int i = 0; i < habitNames.length; i++)
                  if (progression.containsKey(habitNames[i]))
                    myLineChartBarData(
                      spots: progression[habitNames[i]]!,
                      color:
                          i < lineColors.length ? lineColors[i] : Colors.grey,
                      label:
                          chartState.isAll.value == true
                              ? '${habitNames[i]} (7d)'
                              : '${habitNames[i]} (30d)',
                    ),
            ],
          ),
        );
      }),
    );
  }
}
