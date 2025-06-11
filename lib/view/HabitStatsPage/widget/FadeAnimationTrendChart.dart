import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/temp_file.dart';

class FadeAnimationTrendChart extends StatelessWidget {
  const FadeAnimationTrendChart({
    super.key,
    required AnimationController animationController,
    required this.trendSpots,
    required this.trendLabels,
    required this.maxTrendValue,
    required this.chartData,
  }) : _animationController = animationController;

  final AnimationController _animationController;
  final List<FlSpot> trendSpots;
  final List<String> trendLabels;
  final double maxTrendValue;
  final List<Map<String, dynamic>> chartData;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
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
            curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
          ),
        ),
        child: BuildTrendChart(
          chartData: chartData,
          trendSpots: trendSpots,
          trendLabels: trendLabels,
          maxTrendValue: maxTrendValue,
        ),
      ),
    );
  }
}
