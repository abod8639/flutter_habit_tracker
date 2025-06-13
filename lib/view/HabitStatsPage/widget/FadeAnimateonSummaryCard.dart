import 'package:flutter/material.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/BuildSummaryCard.dart';

class FadeAnimateonSummaryCard extends StatelessWidget {
  const FadeAnimateonSummaryCard({
    super.key,
    required AnimationController animationController,
    // required this.stats,
  }) : _animationController = animationController;

  final AnimationController _animationController;
  // final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
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
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        ),
        child: BuildSummaryCard(),
      ),
    );
  }
}
