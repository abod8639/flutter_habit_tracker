import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/auth_controller.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/controller/sync_controller.dart';
import 'package:habit_tracker/functions/performSync.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSettingTile.dart';

Widget buildSyncSection(AnimationController animationController) {
  final syncController = Get.put(SyncController());
  final habitController = Get.find<HabitController>();
  final authController = Get.put(AuthController());
  return Builder(
    builder: (context) {
      return Obx(() {
        final user = authController.currentUser;
        if (user != null) {
          // setstate home page

          return Column(
            children: [
              Obx(
                () => buildAnimatedSettingTile(
                  animationController: animationController,
                  context,
                  index: 3,
                  icon: syncController.syncStatus.value == SyncStatus.syncing
                      ? Icons.sync_rounded
                      : Icons.cloud_upload_outlined,
                  title: S.current.syncNow,
                  subtitle: syncController.syncStatusMessage,
                  onTap: syncController.syncStatus.value == SyncStatus.syncing
                      ? null
                      : () => performSync(syncController, habitController),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      });
    },
  );
}
