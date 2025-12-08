import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/controller/auth_controller.dart';
import 'package:habit_tracker/controller/lang_controller.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/functions/clear_all_habit_data.dart';
import 'package:habit_tracker/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/SettingsPage/buildDataSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/%20buildSyncSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAccountSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildNotificationsSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/uildAppearanceSection.dart';
import 'package:habit_tracker/view/auth/loginpage/login_page.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSectionHeader.dart';
import 'package:habit_tracker/controller/notification_controller.dart';
import 'package:habit_tracker/controller/sync_controller.dart';
import 'widget/buildAnimatedSettingTile.dart';

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
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }



  Widget _buildAboutSection() {
    return Column(
      children: [
        buildAnimatedSectionHeader(
          _animationController,
          context,
          S.current.about,
          11,
        ),
        buildAnimatedSettingTile(
          animationController: _animationController,
          context,
          index: 12,
          icon: Icons.info_outline_rounded,
          title: S.current.about,
          subtitle: S.current.appVersionAndInformation,
          onTap: () {
            // TODO: Implement about page
          },
        ),
      ],
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

  Future<void> navigateToLogin() async {
    final settingsStorage = SettingsStorage();
    await settingsStorage.init();
    await settingsStorage.setSkippedLogin(false);
    Get.offAll(() => const LoginPage());
  }

  Future<void> performSync(
    SyncController syncController,
    HabitController habitController,
  ) async {
    final habits = habitController.db.todaysHabitList;
    final result = await syncController.manualSync(habits);
    if (result != null) {
      habitController.updateHabits(result);
    }
  }

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


