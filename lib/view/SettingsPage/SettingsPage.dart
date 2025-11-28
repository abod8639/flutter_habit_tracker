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
    // final habitController = Get.put(HabitController());

    // final ThemeController themeController = Get.find<ThemeController>();
    final LangController controllerlanguage = Get.find<LangController>();
    final AuthController authController = Get.put(AuthController());
    final SyncController syncController = Get.put(SyncController());
    final HabitController habitController = Get.find<HabitController>();

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
          children: [
            // User Account Section
            Obx(() {
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? const Icon(Icons.person, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName ?? S.current.user,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
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
                      icon: Icons.logout,
                      title: S.current.logout,
                      subtitle: S.current.logoutFromAccount,
                      textColor: Colors.red,
                      onTap: () async {
                        Get.defaultDialog(
                          title: S.current.logoutConfirmTitle,
                          middleText: S.current.logoutConfirmMessage,
                          textConfirm: S.current.logout,
                          textCancel: S.current.cancel,
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () async {
                            Get.back(); // Close dialog
                            // Clear skip preference on logout
                            final settingsStorage = SettingsStorage();
                            await settingsStorage.init();
                            await settingsStorage.setSkippedLogin(false);
                            await authController.signOut();
                          },
                        );
                      },
                    ),
                  ],
                );
              } else {
                // Show login option for users who skipped
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
                      icon: Icons.login,
                      title: S.current.loginToAccount,
                      subtitle: S.current.loginToEnableSync,
                      onTap: () async {
                        // Clear skip preference and navigate to login
                        final settingsStorage = SettingsStorage();
                        await settingsStorage.init();
                        await settingsStorage.setSkippedLogin(false);
                        Get.offAll(() => const LoginPage());
                      },
                    ),
                  ],
                );
              }
            }),

            // Cloud Sync Section (only show if logged in)
            Obx(() {
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
                          ? Icons.sync
                          : Icons.cloud_upload_outlined,
                      title: S.current.syncNow,
                      subtitle: syncController.syncStatusMessage,
                      onTap: syncController.syncStatus.value == SyncStatus.syncing
                          ? null
                          : () async {
                              final habits = habitController.db.todaysHabitList;
                              final result = await syncController.manualSync(habits);
                              if (result != null) {
                                habitController.db.todaysHabitList = result;
                              }
                            },
                    )),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            
            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.appearance,
              4,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 3,
              icon: Icons.color_lens,
              title: 'Theme',
              subtitle: S.current.changeAppTheme,
              onTap:
                  () => Get.to(
                    () => const ThemePage(),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 400),
                  ),
            ),

            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.lan,
              4,
            ),

            Obx(
              () => buildAnimatedSettinglang(
                context,
                icon: Icons.language,
                currentValue: controllerlanguage.language.value,
                entries: const [
                  DropdownMenuEntry(value: "sys", label: "  System Language  "),
                  DropdownMenuEntry(value: "ar", label: "  العربية "),
                  DropdownMenuEntry(value: "en", label: "  English  "),
                ],
                onChanged: (value) async {
                  if (value != null) {
                    await controllerlanguage.changeLanguage(value);
                    restart(); // Restart to apply language change
                  }
                },
                textColor: Theme.of(context).colorScheme.onSecondary,
                animationController: _animationController,
                index: 5,
              ),
            ),

            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.notifications,
              6,
            ),

            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 7,
              icon: Icons.notifications,
              title: S.current.dailyReminder,
              subtitle: S.current.setDailyReminder,
              trailing: Obx(() {
                final controller = Get.find<NotificationController>();
                return Switch(
                  value: controller.isNotificationEnabled.value,
                  onChanged: (value) async {
                    await controller.toggleNotification(value);
                    if (value && context.mounted) {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: controller.notificationTime.value ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        await controller.setNotificationTime(picked);
                        if (context.mounted) {
                          Get.snackbar('Success', 'Reminder set for ${picked.format(context)}');
                        }
                      } else {
                        // If user cancels time picker, maybe keep it enabled with default/previous time
                        // or disable it? For now, let's keep it enabled with default/previous time.
                        if (controller.notificationTime.value == null) {
                           // If no time was set before, maybe disable it again?
                           // Or just let the controller handle the default time as implemented.
                        }
                      }
                    } else {
                      Get.snackbar('Success', 'Notifications disabled');
                    }
                  },
                );
              }),
              onTap: () async {
                 final controller = Get.find<NotificationController>();
                 if (controller.isNotificationEnabled.value && context.mounted) {
                    final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: controller.notificationTime.value ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        await controller.setNotificationTime(picked);
                        if (context.mounted) {
                          Get.snackbar('Success', 'Reminder set for ${picked.format(context)}');
                        }
                      }
                 }
              },
            ),
            buildAnimatedSectionHeader(
              _animationController,
              context,
              'Data',
              8,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 9,
              icon: Icons.backup,
              title: S.current.backupData,
              subtitle: S.current.exportYourHabitData,
              onTap: () async {
                //                 SupabaseService.uploadHabits(
                //   habitController.db.todaysHabitList,
                // "1234"
                //                   // Get.put(SupabaseService()).client.auth.currentUser!.id,

                //                 );
                showComingSoon(context);
              },
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 10,
              icon: Icons.restore,
              title: S.current.restoreData,
              subtitle: S.current.importPreviouslyExportedData,
              onTap: () {},
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 11,
              icon: Icons.delete_outline,
              title: S.current.clearAllData,
              subtitle: S.current.deleteAllHabitsAndSettings,
              textColor: Colors.red,
              onTap: () async => await clearAppDataAndRestart(context),
              //  {
              //   Get.defaultDialog(
              //     title: 'Clear All Data',
              //     middleText:
              //         'Are you sure you want to delete all your habits and settings? This action cannot be undone.',
              //     textConfirm: 'Delete',
              //     textCancel: 'Cancel',
              //     confirmTextColor: Colors.white,
              //     buttonColor: Colors.red,
              //     onConfirm: () async {
              //       // clearAppDataAndRestart(context);
              //     },
              //   );
              // },
            ),

            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.about,
              12,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 13,
              icon: Icons.info_outline,
              title: S.current.about,
              subtitle: S.current.appVersionAndInformation,
              onTap: () {
                // showComingSoon(context);
              },
            ),
            // buildAnimatedSettingTile(
            //   animationController: _animationController,
            //   context,
            //   index: 11,
            //   icon: Icons.star_outline,
            //   title: 'Rate App',
            //   subtitle: 'If you enjoy using this app, please rate it',
            //   onTap: () {
            //     showComingSoon(context);
            //   },
            // ),
            const SizedBox(height: 24), // Add space at the bottom
          ],
        ),
      ),
    );
  }
}

void showComingSoon(dynamic context) {
  Get.snackbar(
    S.current.comingSoon,
    S.current.restoreFeatureWillBeAvailableInFutureUpdates,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 2),
    animationDuration: const Duration(milliseconds: 500),
  );
}

void restart() {
  RestartWidget.restartApp(Get.context!);
}
