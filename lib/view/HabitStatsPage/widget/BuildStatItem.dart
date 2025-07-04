import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';

Widget BuildStatItem(String title, String value, IconData icon, Color color) {
  final controller = Get.put(HabitController());

  return Expanded(
    child: Builder(
      builder: (context) {
        final mSize = MediaQuery.of(context).size.width *.030;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,

                  size: controller.isPhone(context) ? 18 : 22,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: controller.isPhone(context) ? mSize : 18,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: color,
              ),
            ),
          ],
        );
      },
    ),
  );
}
