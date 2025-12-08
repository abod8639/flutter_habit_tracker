
  import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:habit_tracker/controller/auth_controller.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/controller/sync_controller.dart';
import 'package:habit_tracker/view/SettingsPage/SettingsPage.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSectionHeader.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSettingTile.dart';

Widget buildSyncSection(
    AuthController authController,
    SyncController syncController,
    HabitController habitController,
    AnimationController _animationController
  ) {
    return Builder(
      builder: (context) {
        return Obx(() {
          final user = authController.currentUser;
          if (user != null) {
            // setstate home page 
        
            return Column(
              children: [
                buildAnimatedSectionHeader(
                  _animationController,
                  context,
                  S.current.cloudSync,
                  2,
                ),
                Obx(() => buildAnimatedSettingTile(
                      animationController: _animationController,
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
                    )),
              ],
            );
          }
          return const SizedBox.shrink();
        });
      }
    );
  }
