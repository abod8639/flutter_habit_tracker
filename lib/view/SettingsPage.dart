import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/view/ThemePage.dart';

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
            _buildAnimatedSectionHeader(context, 'Appearance', 0),
            _buildAnimatedSettingTile(
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

            // _buildAnimatedSettingTile(
            //   context,
            //   index: 2,
            //   icon: Icons.dark_mode,
            //   title: 'Dark Mode',
            //   subtitle: 'Toggle between light and dark mode',
            //   trailing: Obx(
            //     () => Switch(
            //       value: themeController.themeMode.value == ThemeMode.dark,
            //       onChanged: (value) {
            //         themeController.changeThemeMode(
            //           value ? ThemeMode.dark : ThemeMode.light,
            //         );
            //       },
            //     ),
            //   ),
            //   onTap: () {},
            // ),
            _buildAnimatedSectionHeader(context, 'Notifications', 3),
            _buildAnimatedSettingTile(
              context,
              index: 4,
              icon: Icons.notifications,
              title: 'Daily Reminder',
              subtitle: 'Set a daily reminder for your habits',
              trailing: Switch(
                value: false, // Connect to actual notification settings
                onChanged: (value) {
                  // Implement notification toggle
                  Get.snackbar(
                    'Coming Soon',
                    'Notification feature will be available in future updates',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    animationDuration: const Duration(milliseconds: 500),
                  );
                },
              ),
              onTap: () {},
            ),

            _buildAnimatedSectionHeader(context, 'Data', 5),
            _buildAnimatedSettingTile(
              context,
              index: 6,
              icon: Icons.backup,
              title: 'Backup Data',
              subtitle: 'Export your habit data',
              onTap: () {
                Get.snackbar(
                  'Coming Soon',
                  'Backup feature will be available in future updates',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  animationDuration: const Duration(milliseconds: 500),
                );
              },
            ),
            _buildAnimatedSettingTile(
              context,
              index: 7,
              icon: Icons.restore,
              title: 'Restore Data',
              subtitle: 'Import previously exported data',
              onTap: () {
                Get.snackbar(
                  'Coming Soon',
                  'Restore feature will be available in future updates',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  animationDuration: const Duration(milliseconds: 500),
                );
              },
            ),
            _buildAnimatedSettingTile(
              context,
              index: 8,
              icon: Icons.delete_outline,
              title: 'Clear All Data',
              subtitle: 'Delete all habits and settings',
              textColor: Colors.red,
              onTap: () {
                Get.defaultDialog(
                  title: 'Clear All Data',
                  middleText:
                      'Are you sure you want to delete all your habits and settings? This action cannot be undone.',
                  textConfirm: 'Delete',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    // Implement data clearing functionality
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Clear data feature will be available in future updates',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                      animationDuration: const Duration(milliseconds: 500),
                    );
                  },
                );
              },
            ),

            _buildAnimatedSectionHeader(context, 'About', 9),
            _buildAnimatedSettingTile(
              context,
              index: 10,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {
                Get.defaultDialog(
                  title: 'Habit Tracker',
                  middleText:
                      'Version 1.0.0\n\nA simple app to track your daily habits.',
                  textConfirm: 'OK',
                  confirmTextColor: Colors.white,
                  onConfirm: () => Get.back(),
                );
              },
            ),
            _buildAnimatedSettingTile(
              context,
              index: 11,
              icon: Icons.star_outline,
              title: 'Rate App',
              subtitle: 'If you enjoy using this app, please rate it',
              onTap: () {
                Get.snackbar(
                  'Coming Soon',
                  'Rating feature will be available in future updates',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  animationDuration: const Duration(milliseconds: 500),
                );
              },
            ),
            const SizedBox(height: 24), // Add space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSectionHeader(
    BuildContext context,
    String title,
    int index,
  ) {
    final Animation<double> animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.05 * (index % 10),
        math.min(0.05 * (index % 10) + 0.5, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.2, 0),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSettingTile(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    final Animation<double> animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.05 * (index % 10),
        math.min(0.05 * (index % 10) + 0.5, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(animation),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(icon, color: Theme.of(context).primaryColor),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
            subtitle: Text(subtitle),
            trailing: trailing,
            onTap: () {
              // Apply a scale animation on tap
              final RenderBox? box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                // final position = box.localToGlobal(Offset.zero);
                // final size = box.size;

                Get.showOverlay(
                  asyncFunction: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    onTap();
                  },
                  loadingWidget: const SizedBox(),
                  opacityColor: Colors.transparent,
                  opacity: 0,
                );
              } else {
                onTap();
              }
            },
          ),
        ),
      ),
    );
  }
}
