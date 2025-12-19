  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/notification_controller.dart';
import 'package:habit_tracker/functions/handleNotificationToggle.dart';
import 'package:habit_tracker/functions/myShowTimePicker.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSettingTile.dart';

Widget buildNotificationsSection( AnimationController animationController) {
    final notificationController = Get.find<NotificationController>();
    return Builder(
      builder: (context) {
        return Column(
          children: [

            buildAnimatedSettingTile(
              animationController: animationController,
              context,
              index: 8,
              icon: Icons.notifications_rounded,
              title: S.current.dailyReminder,
              subtitle: S.current.setDailyReminder,
              trailing: Obx(() => Switch(
                    value: notificationController.isNotificationEnabled.value,
                    onChanged: (value) => handleNotificationToggle(notificationController, value, context),
                  )),
              onTap: () => myShowTimePicker(notificationController, context),
            ),
          ],
        );
      }
    );
  }