import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/controller/auth_controller.dart';
import 'package:habit_tracker/controller/lang_controller.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/SettingsPage/buildDataSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/%20buildSyncSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAboutSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAccountSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildNotificationsSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/uildAppearanceSection.dart';
import 'package:habit_tracker/controller/notification_controller.dart';
import 'package:habit_tracker/controller/sync_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final langController = Get.find<LangController>();
    final authController = Get.put(AuthController());
    final syncController = Get.put(SyncController());
    final habitController = Get.find<HabitController>();
    final notificationController = Get.find<NotificationController>();

    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyboardShortCutsPages(event),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(S.current.settingPageTitle),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            buildAccountSection(authController, _animationController),
            buildSyncSection(authController, syncController, habitController, _animationController),
            buildAppearanceSection(langController, _animationController),
            buildNotificationsSection(notificationController, _animationController),
            buildDataSection(_animationController),
            buildAboutSection(_animationController),
          ],
        ),
      ),
    );
  }

}

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








