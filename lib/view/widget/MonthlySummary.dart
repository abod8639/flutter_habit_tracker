import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/models/date_time.dart';

class MonthlySummary extends StatefulWidget {
  final Map<DateTime, int> datasets;

  const MonthlySummary({super.key, required this.datasets});

  @override
  State<MonthlySummary> createState() => _MonthlySummaryState();
}

class _MonthlySummaryState extends State<MonthlySummary>
    with SingleTickerProviderStateMixin {
  final habitController = Get.put(HabitController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  double _heatMapSize = 37;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

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
      startDateTime = createDateTimeObject(habitController.getStartDay());
    } catch (e) {
      startDateTime = DateTime.now().subtract(const Duration(days: 30));
    }

    final themeColors = Theme.of(context).colorScheme;
    final primaryColor = themeColors.primary;

    final colorsets = {
      1: primaryColor.withValues(alpha: 0.1),
      2: primaryColor.withValues(alpha: 0.2),
      3: primaryColor.withValues(alpha: 0.3),
      4: primaryColor.withValues(alpha: 0.4),
      5: primaryColor.withValues(alpha: 0.5),
      6: primaryColor.withValues(alpha: 0.6),
      7: primaryColor.withValues(alpha: 0.7),
      8: primaryColor.withValues(alpha: 0.8),
      9: primaryColor.withValues(alpha: 0.9),
      10: primaryColor.withValues(alpha: 1.0),
    };

    final double topPadding = MediaQuery.of(context).size.width * 0.05;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _heatMapSize = 27;
        });
      },
      onLongPressUp: () {
        setState(() {
          _heatMapSize = 37;
        });
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_animationController),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 2, top: topPadding, bottom: 25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: HeatMap(
                    startDate: startDateTime,
                    fontSize: 16,
                    endDate: DateTime.now().add(const Duration(days: 15)),
                    colorMode: ColorMode.color,
                    defaultColor: Colors.grey[400]!.withAlpha(20),
                    textColor: themeColors.onSurface,
                    showColorTip: false,
                    showText: true,
                    scrollable: true,
                    size: _heatMapSize,
                    colorsets: colorsets,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 2.6,
                  top: topPadding,
                  bottom: 25,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: HeatMap(
                    startDate: startDateTime,
                    fontSize: 16,
                    endDate: DateTime.now(),
                    datasets: widget.datasets,
                    colorMode: ColorMode.color,
                    defaultColor: Colors.grey[400]!,
                    textColor: themeColors.onSurface,
                    showColorTip: false,
                    showText: true,
                    scrollable: true,
                    size: _heatMapSize,
                    colorsets: colorsets,
                    onClick: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(100),
                          duration: const Duration(seconds: 1),
                          content: Center(
                            child: Text(
                              value.toString().replaceAll("00:00:00.000", " "),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
