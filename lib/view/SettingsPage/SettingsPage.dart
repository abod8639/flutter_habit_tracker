import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/functions/clearAllHabitData.dart';
import 'package:habit_tracker/utils/restart_widget.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSectionHeader.dart';
import 'package:habit_tracker/view/ThemePage/ThemePage.dart';

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
    // final ThemeController themeController = Get.find<ThemeController>();

    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        // Skip handling special keys like NumLock to avoid conflicts
        if (event.physicalKey == PhysicalKeyboardKey.numLock) {
          return;
        }

        if (event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.backspace) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Settings'),
          elevation: 0,
        ),
        body: ListView(
          children: [
            buildAnimatedSectionHeader(
              _animationController,
              context,
              'Appearance',
              0,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 1,
              icon: Icons.color_lens,
              title: 'Theme',
              subtitle: 'Change app theme and colors',
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
              'Notifications',
              3,
            ),

            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 4,
              icon: Icons.notifications,
              title: 'Daily Reminder',
              subtitle: 'Set a daily reminder for your habits',
              trailing: Switch(
                value: false, // Connect to actual notification settings
                onChanged: (value) {
                  // Implement notification toggle
                  showComingSoon();
                },
              ),
              onTap: () {},
            ),

            buildAnimatedSectionHeader(
              _animationController,
              context,
              'Data',
              5,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 6,
              icon: Icons.backup,
              title: 'Backup Data',
              subtitle: 'Export your habit data',
              onTap: () {
                showComingSoon();
              },
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 7,
              icon: Icons.restore,
              title: 'Restore Data',
              subtitle: 'Import previously exported data',
              onTap: () {},
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 8,
              icon: Icons.delete_outline,
              title: 'Clear All Data',
              subtitle: 'Delete all habits and settings',
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
              'About',
              9,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 10,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {
                showComingSoon();
              },
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 11,
              icon: Icons.star_outline,
              title: 'Rate App',
              subtitle: 'If you enjoy using this app, please rate it',
              onTap: () {
                showComingSoon();
              },
            ),
            const SizedBox(height: 24), // Add space at the bottom
          ],
        ),
      ),
    );
  }
}

void showComingSoon() {
  Get.snackbar(
    'Coming Soon',
    'Restore feature will be available in future updates',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 2),
    animationDuration: const Duration(milliseconds: 500),
  );
}

void restart() {
  RestartWidget.restartApp(Get.context!);
}
