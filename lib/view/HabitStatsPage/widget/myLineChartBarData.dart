import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

LineChartBarData myLineChartBarData({
  required List<FlSpot> spots,
  required Color color,
  String? habitName,
}) {
  return LineChartBarData(
    show: true,
    spots: spots,
    isCurved: true,
    color: color,
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: true),
    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
  );
}
