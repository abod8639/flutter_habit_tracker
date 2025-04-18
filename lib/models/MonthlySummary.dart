import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/models/date_time.dart';

class MonthlySummary extends StatefulWidget {
  final Map<DateTime, int> datasets;
  final String startDate;

  const MonthlySummary({
    super.key,
    required this.datasets,
    required this.startDate,
  });

  @override
  State<MonthlySummary> createState() => _MonthlySummaryState();
}

class _MonthlySummaryState extends State<MonthlySummary>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDateTime;
    try {
      startDateTime = createDateTimeObject(widget.startDate);
    } catch (e) {
      startDateTime = DateTime.now().subtract(const Duration(days: 30));
    }

    final themeColors = Theme.of(context).colorScheme;
    final primaryColor = themeColors.primary;

    final colorsets = {
      1: primaryColor.withOpacity(0.1),
      2: primaryColor.withOpacity(0.2),
      3: primaryColor.withOpacity(0.3),
      4: primaryColor.withOpacity(0.4),
      5: primaryColor.withOpacity(0.5),
      6: primaryColor.withOpacity(0.6),
      7: primaryColor.withOpacity(0.7),
      8: primaryColor.withOpacity(0.8),
      9: primaryColor.withOpacity(0.9),
      10: primaryColor.withOpacity(1.0),
    };

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_animationController),
        child: Container(
          padding: const EdgeInsets.only(top: 25, bottom: 25),
          child: HeatMap(
            startDate: startDateTime,
            endDate: DateTime.now().add(const Duration(days: 0)),
            datasets: widget.datasets,
            colorMode: ColorMode.color,
            defaultColor: Colors.grey[400]!,
            textColor: themeColors.onSurface,
            showColorTip: false,
            showText: true,
            scrollable: true,
            size: 37,
            colorsets: colorsets,
            onClick: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.grey,
                  duration: const Duration(seconds: 1),
                  content: Text(value.toString()),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
