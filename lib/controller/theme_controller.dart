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
      themeMode.value = _storage.getThemeMode();
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

    final isDarkTheme = _isDarkOrientedTheme(currentTheme.value);
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

  bool _isDarkOrientedTheme(String themeName) {
    const darkThemes = [
      'github_dark_green',
      'github_dark',
      'midnight',
      'carbon',
      'catppuccin',
      'catppuccin_frappe',
      'catppuccin_macchiato',
      'catppuccin_mocha',
      'dracula',
      'nord',
      'tokyo_night',
      'one_dark',
      'sunset_theme',
      'cyberpunk_neon',
      'hologram',
      'cyber_grid',
      'neo_tokyo',
      'neon_circuit',
      'futuristic_space',
    ];
    return darkThemes.contains(themeName);
  }
}
