  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:habit_tracker/controller/notification_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

Future<void> myShowTimePicker(NotificationController controller , BuildContext context) async {
    if (!controller.isNotificationEnabled.value || !context.mounted) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.notificationTime.value ?? TimeOfDay.now(),
    );

    if (picked != null && context.mounted) {
      await controller.setNotificationTime(picked);
      Get.snackbar(
        S.current.success,
        'Reminder set for ${picked.format(context)}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }