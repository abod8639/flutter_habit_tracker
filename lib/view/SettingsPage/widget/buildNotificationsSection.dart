  import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:habit_tracker/controller/notification_controller.dart';
import 'package:habit_tracker/functions/handleNotificationToggle.dart';
import 'package:habit_tracker/functions/myShowTimePicker.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSectionHeader.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSettingTile.dart';

Widget buildNotificationsSection(NotificationController controller , AnimationController _animationController) {
    return Builder(
      builder: (context) {
        return Column(
          children: [
            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.notifications,
              7,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 8,
              icon: Icons.notifications_rounded,
              title: S.current.dailyReminder,
              subtitle: S.current.setDailyReminder,
              trailing: Obx(() => Switch(
                    value: controller.isNotificationEnabled.value,
                    onChanged: (value) => handleNotificationToggle(controller, value, context),
                  )),
              onTap: () => myShowTimePicker(controller, context),
            ),
          ],
        );
      }
    );
  }