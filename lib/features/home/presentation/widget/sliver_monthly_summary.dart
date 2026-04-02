import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/core/components/monthly_summary.dart';

class SliverMonthlySummary extends StatelessWidget {
  const SliverMonthlySummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    return SliverToBoxAdapter(
      child: Center(
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Obx(() => MonthlySummary(
              datasets: controller.heatmapDateSet,
            )),
          ),
        ),
      ),
    );
  }
}
