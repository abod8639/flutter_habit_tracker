import 'package:flutter/material.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildHabitListCard.dart';

class FaedAnimationHabitListCard extends StatelessWidget {
  const FaedAnimationHabitListCard({
    super.key,
    required AnimationController animationController,
    required this.chartData,
  }) : _animationController = animationController;

  final AnimationController _animationController;
  final List<Map<String, dynamic>> chartData;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
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
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: BuildHabitListCard(context, chartData),
      ),
    );
  }
}
