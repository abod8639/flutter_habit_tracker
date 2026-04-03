import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
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
      await authController.signOut();
    },
  );
}
