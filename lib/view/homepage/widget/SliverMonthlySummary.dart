
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/view/widget/MonthlySummary.dart';

class SliverMonthlySummary extends StatelessWidget {
  const SliverMonthlySummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
      final HabitController controller = Get.put(HabitController());

    return SliverToBoxAdapter(
      child: Center(
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: MonthlySummary(
              datasets: controller.db.heatmapDateSet,
            ),
          ),
        ),
      ),
    );
  }
}
