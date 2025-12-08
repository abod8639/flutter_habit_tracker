  import 'package:get/get.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/view/auth/loginpage/login_page.dart';

Future<void> navigateToLogin() async {
    final settingsStorage = SettingsStorage();
    await settingsStorage.init();
    await settingsStorage.setSkippedLogin(false);
    Get.offAll(() => const LoginPage());
  }
