import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

LineChartBarData myLineChartBarData({
  required List<FlSpot> spots,
  required Color color,
  String? label,
}) {
  return LineChartBarData(
    show: true,
    curveSmoothness: 0.30,
    spots: spots,
    isCurved: true,
    color: color,
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: true),
    belowBarData: BarAreaData(show: true, color: color.withValues(alpha:0.2)),
  );
}
