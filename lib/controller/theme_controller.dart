import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/themeList.dart';
import 'package:habit_tracker/services/theme_storage.dart';
import 'package:habit_tracker/utils/theme_utils.dart';

class ThemeController extends GetxController {
  static const String defaultTheme = 'github_dark_green';

  // Observable state
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxString currentTheme = defaultTheme.obs;
  final RxBool useCustomBackground = false.obs;
  final Rx<Color> customBackgroundColor = Colors.transparent.obs;
  final Rx<ThemeData> lightTheme = ThemeData.light().obs;
  final Rx<ThemeData> darkTheme = ThemeData.dark().obs;

  // Dependencies
  late final ThemeStorageService _storage;

  // Getters
  List<String> get availableThemes => themeColors.keys.toList();

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    try {
      _storage = await ThemeStorageService.init();
      _loadSavedTheme();
    } catch (e) {
      debugPrint('Error initializing theme: $e');
      _setDefaultTheme();
    }
  }

  void _loadSavedTheme() {
    try {
      // Load saved settings
      currentTheme.value = _storage.getThemeName(defaultTheme);
      themeMode.value = ThemeMode.light;
      // _storage.getThemeMode();
      useCustomBackground.value = _storage.getUseCustomBackground();

      final savedBgColor = _storage.getCustomBackgroundColor();
      if (savedBgColor != null) {
        customBackgroundColor.value = savedBgColor;
      }

      // Build and apply themes
      _buildBothThemes();
      _applyTheme();
    } catch (e) {
      debugPrint('Error loading saved theme: $e');
      _setDefaultTheme();
    }
  }

  void _setDefaultTheme() {
    currentTheme.value = defaultTheme;
    themeMode.value = ThemeMode.system;
    useCustomBackground.value = false;
    customBackgroundColor.value = Colors.transparent;
    _buildBothThemes();
    _applyTheme();
    update();
  }

  Future<void> _saveThemeSettings() async {
    try {
      await _storage.saveThemeSettings(
        themeName: currentTheme.value,
        mode: themeMode.value,
        useCustomBg: useCustomBackground.value,
        customBgColor:
            useCustomBackground.value ? customBackgroundColor.value : null,
      );
    } catch (e) {
      debugPrint('Error saving theme settings: $e');
    }
    update();
  }

  void changeThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _buildBothThemes();
    _applyTheme();
    _saveThemeSettings();
  }

  void changeCustomTheme(String themeName) {
    if (themeColors.containsKey(themeName)) {
      currentTheme.value = themeName;
      _buildBothThemes();
      _applyTheme();
      _saveThemeSettings();
    } else {
      Get.snackbar('Error', 'Theme not found');
    }
  }

  void changeBackgroundColor(Color color) {
    customBackgroundColor.value = color;
    useCustomBackground.value = true;
    _buildBothThemes();
    _applyTheme();
    _saveThemeSettings();
  }

  void resetBackgroundColor() {
    useCustomBackground.value = false;
    _buildBothThemes();
    _applyTheme();
    _saveThemeSettings();
  }

  void _applyTheme() {
    Get.changeThemeMode(themeMode.value);
    Get.changeTheme(
      themeMode.value == ThemeMode.dark ? darkTheme.value : lightTheme.value,
    );
  }

  void _buildBothThemes() {
    final themeData = themeColors[currentTheme.value];
    if (themeData == null) return;

    final isDarkTheme = _isDarkTheme(themeData);
    final customBg =
        useCustomBackground.value ? customBackgroundColor.value : null;

    lightTheme.value = ThemeUtils.buildThemeData(
      forceDark: false,
      colors: themeData,
      isDarkTheme: isDarkTheme,
      customBackground: customBg,
    );

    darkTheme.value = ThemeUtils.buildThemeData(
      forceDark: true,
      colors: themeData,
      isDarkTheme: isDarkTheme,
      customBackground: customBg,
    );
  }

  // New method to automatically detect if a theme is dark based on its colors
  bool _isDarkTheme(Map<String, dynamic> themeColors) {
    // Check if the theme explicitly defines if it's dark
    if (themeColors.containsKey('isDark')) {
      return themeColors['isDark'] == true;
    }

    // If not explicitly defined, analyze the colors to determine if it's dark
    // Get the primary or background color to analyze
    Color colorToAnalyze;

    if (themeColors.containsKey('backgroundColor')) {
      // If backgroundColor is available, use it
      colorToAnalyze = _parseColor(themeColors['backgroundColor']);
    } else if (themeColors.containsKey('primaryColor')) {
      // Otherwise use primaryColor
      colorToAnalyze = _parseColor(themeColors['primaryColor']);
    } else if (themeColors.containsKey('scaffoldBackgroundColor')) {
      // Or scaffoldBackgroundColor
      colorToAnalyze = _parseColor(themeColors['scaffoldBackgroundColor']);
    } else {
      // Default to considering it light if we can't determine
      return false;
    }

    // Calculate the brightness using the HSP color model
    // (perceived brightness) which is more accurate than just luminance
    double r = colorToAnalyze.r / 255;
    double g = colorToAnalyze.g / 255;
    double b = colorToAnalyze.b / 255;

    // HSP (Highly Sensitive Poo) equation from http://alienryderflex.com/hsp.html
    double hsp = Math.sqrt(0.299 * (r * r) + 0.587 * (g * g) + 0.114 * (b * b));

    // If perceived brightness is less than 0.5, consider it dark
    return hsp < 0.5;
  }

  // Helper method to parse color from various formats
  Color _parseColor(dynamic colorValue) {
    if (colorValue is Color) {
      return colorValue;
    } else if (colorValue is int) {
      return Color(colorValue);
    } else if (colorValue is String && colorValue.startsWith('#')) {
      // Parse hex color string
      String hex = colorValue.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if not present
      }
      return Color(int.parse(hex, radix: 16));
    }

    // Default fallback
    return Colors.grey;
  }
}
