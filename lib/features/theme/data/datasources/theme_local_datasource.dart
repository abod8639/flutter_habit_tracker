import 'package:habit_tracker/data/theme_storage.dart';
import '../models/theme_model.dart';

abstract class ThemeLocalDataSource {
  Future<ThemeModel> getThemeSettings();
  Future<void> saveThemeSettings(ThemeModel settings);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final ThemeStorageService storageService;

  ThemeLocalDataSourceImpl(this.storageService);

  @override
  Future<ThemeModel> getThemeSettings() async {
    final themeName = storageService.getThemeName('github_dark_green');
    final themeMode = storageService.getThemeMode();
    final useCustomBg = storageService.getUseCustomBackground();
    final customBgColor = storageService.getCustomBackgroundColor();

    return ThemeModel(
      themeName: themeName,
      themeMode: themeMode,
      useCustomBackground: useCustomBg,
      customBackgroundColor: customBgColor,
    );
  }

  @override
  Future<void> saveThemeSettings(ThemeModel settings) async {
    await storageService.saveThemeSettings(
      themeName: settings.themeName,
      mode: settings.themeMode,
      useCustomBg: settings.useCustomBackground,
      customBgColor: settings.customBackgroundColor,
    );
  }
}
