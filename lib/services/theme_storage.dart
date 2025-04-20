import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeStorageService {
  static const String themeBox = "Theme_db";
  static const String themeNameKey = "current_theme";
  static const String themeModeKey = "theme_mode";
  static const String useCustomBgKey = "use_custom_bg";
  static const String customBgColorKey = "custom_bg_color";

  final Box _box;

  ThemeStorageService(this._box);

  static Future<ThemeStorageService> init() async {
    final box = await Hive.openBox(themeBox);
    return ThemeStorageService(box);
  }

  String getThemeName(String defaultTheme) {
    return _box.get(themeNameKey, defaultValue: defaultTheme);
  }

  // ThemeMode getThemeMode() {
  //   final String? mode = _box.get(themeModeKey);
  //   switch (mode) {
  //     case "ThemeMode.dark":
  //       return ThemeMode.dark;
  //     case "ThemeMode.light":
  //       return ThemeMode.light;
  //     default:
  //       return ThemeMode.system;
  //   }
  // }

  bool getUseCustomBackground() {
    return _box.get(useCustomBgKey, defaultValue: false);
  }

  Color? getCustomBackgroundColor() {
    final int? colorValue = _box.get(customBgColorKey);
    return colorValue != null ? Color(colorValue) : null;
  }

  Future<void> saveThemeSettings({
    required String themeName,
    required ThemeMode mode,
    required bool useCustomBg,
    Color? customBgColor,
  }) async {
    await _box.put(themeNameKey, themeName);
    await _box.put(themeModeKey, mode.toString());
    await _box.put(useCustomBgKey, useCustomBg);
    if (customBgColor != null) {
      await _box.put(customBgColorKey, customBgColor.value);
    }
  }
}
