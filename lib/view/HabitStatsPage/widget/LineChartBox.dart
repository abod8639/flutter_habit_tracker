import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/myLineChartBarData.dart';

class LineChartBox extends StatelessWidget {
  const LineChartBox({
    super.key,
    required this.habitNames,
    required this.habitProgression,
    required this.lineColors,
    required this.trendLabels,
    required this.maxTrendValue,
  });

  final List<String> habitNames;
  final Map<String, List<double>> habitProgression;
  final List<Color> lineColors;
  final List<String> trendLabels;
  final double maxTrendValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
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
                  return const Text('');
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
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          minX: 0,
          maxX: trendLabels.length - 1.0,
          minY: 0,
          maxY: maxTrendValue,
          lineBarsData: [
            for (int i = 0; i < habitNames.length; i++)
              myLineChartBarData(
                spots: List.generate(
                  habitProgression[habitNames[i]]!.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    habitProgression[habitNames[i]]![index],
                  ),
                ),
                color: lineColors[i % lineColors.length],
                habitName: habitNames[i],
              ),
          ],
        ),
      ),
    );
  }
}
