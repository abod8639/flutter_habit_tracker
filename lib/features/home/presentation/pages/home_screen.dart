import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/functions/perform_sync.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/pages/phone.dart';
import 'package:habit_tracker/features/home/presentation/pages/tablet.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
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
    final syncController = Get.find<SyncController>();
    performSync(syncController, controller);
    return ResponsiveUtils.isPhone(context) ? const Phone() : const Tablet();
  }
}
