import 'package:flutter/material.dart';
import 'package:habit_tracker/view/HabitStatsPage/widget/buildChartsSection.dart';

class FadeAnimationChartsSection extends StatelessWidget {
  const FadeAnimationChartsSection({
    super.key,
    required AnimationController animationController,
  }) : _animationController = animationController;

  final AnimationController _animationController;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
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
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        ),
        child: buildChartsSection(context),
      ),
    );
  }
}
