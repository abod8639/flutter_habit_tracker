import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/view/homepage/Responsive/Phone.dart';
import 'package:habit_tracker/view/homepage/Responsive/Tablet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HabitController>(
      builder: (controller) => _buildResponsiveLayout(context, controller),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    HabitController controller,
  ) {
    return controller.isPhone(context) ? const Phone() : const Tablet();
  }
}
