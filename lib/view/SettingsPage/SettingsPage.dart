import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/langController.Getx.dart';
import 'package:habit_tracker/functions/clearAllHabitData.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/utils/restart_widget.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSectionHeader.dart';
import 'package:habit_tracker/view/SettingsPage/widget/lang.dart';
import 'package:habit_tracker/view/ThemePage/ThemePage.dart';

import 'widget/buildAnimatedSettingTile.dart';

class SettingsPage extends StatefulWidget {
  //   try {
  //   await SupabaseService.initialize();
  // } catch (e) {
  //   debugPrint('⚠️ Supabase initialization failed, app will work offline: $e');
  // }
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
    final LangController controllerlanguage = Get.put(LangController());

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
          title: Text(S.current.SettingPageTitle),
          elevation: 0,
        ),
        body: ListView(
          children: [
            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.Appearance,
              0,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 1,
              icon: Icons.color_lens,
              title: 'Theme',
              subtitle: S.current.Changeapptheme,
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
              3,
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
                index: 2,
              ),
            ),

            buildAnimatedSectionHeader(
              _animationController,
              context,
              S.current.Notifications,
              3,
            ),

            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 4,
              icon: Icons.notifications,
              title: S.current.DailyReminder,
              subtitle: S.current.SetDailyReminder,
              trailing: Switch(
                value: false, // Connect to actual notification settings
                onChanged: (value) {
                  // Implement notification toggle
                  showComingSoon(context);
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
              title: S.current.BackupData,
              subtitle: S.current.Exportyourhabitdata,
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
              index: 7,
              icon: Icons.restore,
              title: S.current.RestoreData,
              subtitle: S.current.Importpreviouslyexporteddata,
              onTap: () {},
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 8,
              icon: Icons.delete_outline,
              title: S.current.ClearAllData,
              subtitle: S.current.Deleteallhabitsandsettings,
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
              S.current.About,
              9,
            ),
            buildAnimatedSettingTile(
              animationController: _animationController,
              context,
              index: 10,
              icon: Icons.info_outline,
              title: S.current.About,
              subtitle: S.current.Appversionandinformation,
              onTap: () {
                showComingSoon(context);
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

void showComingSoon(context) {
  Get.snackbar(
    S.current.ComingSoon,
    S.current.Restorefeaturewillbeavailableinfutureupdates,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 2),
    animationDuration: const Duration(milliseconds: 500),
  );
}

void restart() {
  RestartWidget.restartApp(Get.context!);
}
