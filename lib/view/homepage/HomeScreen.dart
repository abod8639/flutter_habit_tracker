import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/view/homepage/Responsive/Phone.dart';
import 'package:habit_tracker/view/homepage/Responsive/Tablet.dart';
import 'package:habit_tracker/utils/responsive_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HabitController>()) {
      Get.put(HabitController());
    }
    
    return _buildResponsiveLayout(context, Get.find<HabitController>());
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    HabitController controller,
  ) {
    return ResponsiveUtils.isPhone(context) ? const Phone() : const Tablet();
  }
}
