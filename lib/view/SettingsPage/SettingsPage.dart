import 'package:flutter/material.dart';
import 'package:habit_tracker/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildDataSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/%20buildSyncSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAboutSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAccountSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildNotificationsSection.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAppearanceSection.dart';

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
            buildAccountSection(_animationController),
            buildSyncSection(_animationController),
            buildAppearanceSection(_animationController),
            buildNotificationsSection(_animationController),
            buildDataSection(_animationController),
            buildAboutSection(_animationController),
          ],
        ),
      ),
    );
  }
}
