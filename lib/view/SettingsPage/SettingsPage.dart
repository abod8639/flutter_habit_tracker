import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/controller/auth_controller.dart';
import 'package:habit_tracker/controller/lang_controller.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/functions/clear_all_habit_data.dart';
import 'package:habit_tracker/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/utils/restart_widget.dart';
import 'package:habit_tracker/view/auth/login_page.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSectionHeader.dart';
import 'package:habit_tracker/view/SettingsPage/widget/lang.dart';
import 'package:habit_tracker/view/ThemePage/ThemePage.dart';
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
            _buildAccountSection(authController),
            _buildSyncSection(authController, syncController, habitController),
            _buildAppearanceSection(langController),
            _buildNotificationsSection(notificationController),
            _buildDataSection(),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(AuthController authController) {
    return Obx(() {
      final user = authController.currentUser;
      if (user != null) {
        return Column(
          children: [
            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.account,
              0,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? S.current.user,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 1,
              icon: Icons.logout_rounded,
              title: S.current.logout,
              subtitle: S.current.logoutFromAccount,
              textColor: Colors.red,
              onTap: () => _showLogoutDialog(authController),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.account,
              0,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 1,
              icon: Icons.login_rounded,
              title: S.current.loginToAccount,
              subtitle: S.current.loginToEnableSync,
              onTap: () => _navigateToLogin(),
            ),
          ],
        );
      }
    });
  }

  Widget _buildSyncSection(
    AuthController authController,
    SyncController syncController,
    HabitController habitController,
  ) {
    return Obx(() {
      final user = authController.currentUser;
      if (user != null) {
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
                      : () => _performSync(syncController, habitController),
                )),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildAppearanceSection(LangController langController) {
    return Column(
      children: [
        buildAnimatedSectionHeader(
          _animationController,
          context,
          S.current.appearance,
          4,
        ),
        buildAnimatedSettingTile(
          animationController: _animationController,
          context,
          index: 5,
          icon: Icons.palette_rounded,
          title: S.current.themepage,
          subtitle: S.current.changeAppTheme,
          onTap: () => Get.to(
            () => const ThemePage(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 400),
          ),
        ),
        Obx(
          () => buildAnimatedSettinglang(
            context,
            icon: Icons.language_rounded,
            currentValue: langController.language.value,
            entries: const [
              DropdownMenuEntry(value: "sys", label: "  System Language  "),
              DropdownMenuEntry(value: "ar", label: "  العربية "),
              DropdownMenuEntry(value: "en", label: "  English  "),
            ],
            onChanged: (value) async {
              if (value != null) {
                await langController.changeLanguage(value);
                RestartWidget.restartApp(context);
              }
            },
            textColor: Theme.of(context).colorScheme.onSecondary,
            animationController: _animationController,
            index: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(NotificationController controller) {
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
                onChanged: (value) => _handleNotificationToggle(controller, value),
              )),
          onTap: () => _showTimePicker(controller),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      children: [
        buildAnimatedSectionHeader(
          _animationController,
          context,
          'Data',
          9,
        ),
        buildAnimatedSettingTile(
          animationController: _animationController,
          context,
          index: 10,
          icon: Icons.delete_sweep_rounded,
          title: S.current.clearAllData,
          subtitle: S.current.deleteAllHabitsAndSettings,
          textColor: Colors.red,
          onTap: () => clearAppDataAndRestart(context),
        ),
      ],
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

  Future<void> _showLogoutDialog(AuthController authController) async {
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

  Future<void> _navigateToLogin() async {
    final settingsStorage = SettingsStorage();
    await settingsStorage.init();
    await settingsStorage.setSkippedLogin(false);
    Get.offAll(() => const LoginPage());
  }

  Future<void> _performSync(
    SyncController syncController,
    HabitController habitController,
  ) async {
    final habits = habitController.db.todaysHabitList;
    final result = await syncController.manualSync(habits);
    if (result != null) {
      habitController.db.todaysHabitList = result;
    }
  }

  Future<void> _handleNotificationToggle(
    NotificationController controller,
    bool value,
  ) async {
    await controller.toggleNotification(value);
    if (value && context.mounted) {
      await _showTimePicker(controller);
    } else {
      Get.snackbar(
        S.current.success,
        'Notifications disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _showTimePicker(NotificationController controller) async {
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
}
