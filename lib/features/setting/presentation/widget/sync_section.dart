import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_tile.dart';
import 'package:habit_tracker/functions/perform_sync.dart';
import 'package:habit_tracker/generated/l10n.dart';

Widget buildSyncSection(AnimationController animationController) {
  final syncController = Get.put(SyncController());
  final habitController = Get.find<HabitController>();
  final authController = Get.put(AuthController());
  return Obx(() {
    final user = authController.currentUser;
    if (user != null) {
      // setstate home page
      return Column(
        children: [
          Obx(
            () => AnimatedSettingTile(
              animationController: animationController,
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
}
