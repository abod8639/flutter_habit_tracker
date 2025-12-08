  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/notification_controller.dart';
import 'package:habit_tracker/functions/myShowTimePicker.dart';
import 'package:habit_tracker/generated/l10n.dart';

Future<void> handleNotificationToggle(
    NotificationController controller,
    bool value,
    BuildContext context
  ) async {
    await controller.toggleNotification(value);
    if (value && context.mounted) {
      await myShowTimePicker(controller, context);
    } else {
      Get.snackbar(
        S.current.success,
        'Notifications disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
