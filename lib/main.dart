import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';
import 'package:habit_tracker/controller/theme_controller.dart';
import 'package:habit_tracker/page/Responsive/Phone.dart';
import 'package:habit_tracker/page/Responsive/Tablet.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

 Future <void> main() async {
  await Supabase.initialize(
    url: 'https://wpuulmyghraznktpsvkg.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwdXVsbXlnaHJhem5rdHBzdmtnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE3MTA4OTYsImV4cCI6MjA1NzI4Njg5Nn0.4AHXRomMDX5hcOP7870t6CduDyFf7BzwBKUNPhpOwAY'
  );
  //  todo add database
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("Habit_db");
  await Hive.openBox(ThemeController.themeBox);
    // await initServices();

  Get.put(HabitController());
  Get.put(ThemeController());
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(
    //     SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    final ThemeController themeController = Get.put(ThemeController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeController.lightTheme.value,
      darkTheme: themeController.darkTheme.value,
      themeMode: themeController.themeMode.value,
      home: 
      // LoginPage()
       GetBuilder<HabitController>(
        init: HabitController(),
        builder:
            (controller) =>
                controller.isPhone(context) ? const Phone() : const Tablet(),
      ),
    );
  }
}
// Future<void> initServices() async {
//   // تهيئة خدمة Supabase
//   await Get.putAsync(() => SupabaseService().init());
//   // تسجيل خدمة العادات
//   Get.put(HabitService());
//   // تسجيل وحدة التحكم
//   Get.put(HabitController());
// }