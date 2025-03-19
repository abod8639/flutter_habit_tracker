import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/custom/MyListTile.dart';
import 'package:habit_tracker/page/CompletedHabitsPage.dart';
import 'package:habit_tracker/page/HabitStatsPage.dart';
import 'package:habit_tracker/page/IncompleteHabitsPage.dart';
import 'package:habit_tracker/page/ThemePage.dart';

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
    // final ThemeController themeController = Get.find<ThemeController>();
    return ListView(
      children: [
  
        MyListTile(
          icon: Icon(
            color: Colors.greenAccent,
            Icons.check,
          ),
          onTap: () => Get.to(()=> CompletedHabitsPage()),
          title: "Completed Habit",
        ),
    
        MyListTile(
          icon: Icon(
            color: Theme.of(context).colorScheme.error,
            Icons.check_box_outline_blank,
          ),
          onTap: () => Get.to(()=>IncompleteHabitsPage()),
          title: "Incomplete Habit",
        ),
   
        MyListTile(
          icon: Icon(
            color: Theme.of(context).primaryColor,
            Icons.color_lens_outlined,
          ),
          onTap: () {
            Get.back();
            Get.to(()=>ThemePage());
          },
          // buildCustomThemeSelector(themeController),
          title: "Theme Color",
        ),
   
        MyListTile(
          icon: Icon(color: Colors.blueAccent , Icons.auto_graph_sharp ),
          onTap: () {
            Get.back();
          Get.to(()=> HabitStatsPage() );
          },
          title: "Rate",
        ),
       
        MyListTile(
          icon: const Icon(color: Colors.blueGrey, Icons.settings ),
          onTap: () {
            // Get.to(()=>MyApp() );

            Get.back();
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnakBar(context,"Maybe Coming Soon"),
            );
          },
          //  Get.to(const SettingsPage()),
          title: "Settings",
        ),
    
        MyListTile(
          icon: const Icon(color: Colors.blueGrey, Icons.settings ),
          onTap: () {
            // Get.to(()=>LoginPage() );

          },
          title: "Login",
        ),
      
      ],
    );
  }


  SnackBar ErrorSnakBar(BuildContext context , String text) {
    return SnackBar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.error.withOpacity(0.5),
              duration: const Duration(seconds: 1),
              // animation: Animatio
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
