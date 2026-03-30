import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/auth_controller.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/generated/l10n.dart';

Future<void> showLogoutDialog(AuthController authController) async {
  Get.defaultDialog(
    title: S.current.logoutConfirmTitle,
    middleText: S.current.logoutConfirmMessage,
    textConfirm: S.current.logout,
    textCancel: S.current.cancel,
    confirmTextColor: Colors.white,
    buttonColor: Colors.red,
    onConfirm: () async {
      Get.back();
      final settingsStorage = SettingsStorage();
      await settingsStorage.init();
      await settingsStorage.setSkippedLogin(false);
      await authController.signOut();
    },
  );
}
