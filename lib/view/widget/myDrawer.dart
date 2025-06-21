import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/HabitListWidget.dart';
import 'package:habit_tracker/view/HabitStatsPage/HabitStatsPage.dart';
import 'package:habit_tracker/view/SettingsPage/SettingsPage.dart';
import 'package:habit_tracker/view/ThemePage/ThemePage.dart';
import 'package:habit_tracker/view/widget/MyListTile.dart';

class myDrawer extends StatelessWidget {
  const myDrawer({super.key});
  bool isPhone(BuildContext context) {
    final double mwidth = MediaQuery.of(context).size.width;
    return mwidth < 600.0;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: isPhone(context) ? 200 : 300,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // backgroundColor: Colors.grey[900],
      child: DrawerList(),
    );
  }
}

class DrawerList extends StatelessWidget {
  const DrawerList({super.key});

  @override
  Widget build(BuildContext context) {
    // HabitController controller = Get.put(HabitController());

    return ListView(
      children: [
        SizedBox(height: 20),
        MyListTile(
          icon: Icon(
            color: Theme.of(context).primaryColor,
            Icons.color_lens_outlined,
          ),
          onTap: () {
            Get.back();
            Get.to(() => ThemePage());
          },
          title: S.of(context).drawerTheme,
        ),

        MyListTile(
          icon: Icon(color: Colors.blueAccent, Icons.auto_graph_sharp),
          onTap: () {
            Get.back();
            Get.to(() => HabitStatsPage());
          },
          title: S.of(context).drawerReat,
        ),

        MyListTile(
          icon: const Icon(color: Colors.blueGrey, Icons.settings),
          onTap: () {
            Get.to(() => SettingsPage());
          },
          title: S.of(context).drawerSetting,
        ),
        MyListTile(
          icon: const Icon(
            color: Colors.blueGrey,
            Icons.settings_accessibility_sharp,
          ),
          onTap: () {
            // Get.to(() => SupaEmailAuthWidget());
            Get.to(() => HabitListWidget());
          },
          title: "Test page",
        ),
      ],
    );
  }

  SnackBar ErrorSnakBar(BuildContext context, String text) {
    return SnackBar(
      backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.5),
      duration: const Duration(milliseconds: 1500),
      content: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        text,
      ),
    );
  }
}
