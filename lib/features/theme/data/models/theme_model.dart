import 'package:flutter/material.dart';
import '../../domain/entities/theme_entity.dart';

class ThemeModel extends ThemeEntity {
  const ThemeModel({
    required super.themeName,
    required super.themeMode,
    required super.useCustomBackground,
    super.customBackgroundColor,
  });

  factory ThemeModel.fromEntity(ThemeEntity entity) {
    return ThemeModel(
      themeName: entity.themeName,
      themeMode: entity.themeMode,
      useCustomBackground: entity.useCustomBackground,
      customBackgroundColor: entity.customBackgroundColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeName': themeName,
      'themeMode': themeMode.toString(),
      'useCustomBg': useCustomBackground,
      'customBgColor': customBackgroundColor?.toARGB32(),
    };
  }

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      themeName: json['themeName'] ?? 'github_dark_green',
      themeMode: _parseThemeMode(json['themeMode']),
      useCustomBackground: json['useCustomBg'] ?? false,
      customBackgroundColor: json['customBgColor'] != null ? Color(json['customBgColor']) : null,
    );
  }

  static ThemeMode _parseThemeMode(String? modeStr) {
    if (modeStr == 'ThemeMode.dark') return ThemeMode.dark;
    if (modeStr == 'ThemeMode.light') return ThemeMode.light;
    return ThemeMode.system;
  }
}
