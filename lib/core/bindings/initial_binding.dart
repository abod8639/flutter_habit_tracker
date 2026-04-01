import 'package:get/get.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_binding.dart';
import 'package:habit_tracker/features/theme/presentation/controllers/theme_binding.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/setting_binding.dart';
import 'package:habit_tracker/controller/habit_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Auth Feature Dependencies
    AuthBinding().dependencies();

    // 2. Theme Feature Dependencies
    ThemeBinding().dependencies();

    // 3. Setting Feature Dependencies (Language, Notifications, Sync)
    SettingBinding().dependencies();

    // 4. Global Habit Controller
    // Note: This will be refactored to a specific HabitBinding later
    Get.lazyPut(() => HabitController());
  }
}
