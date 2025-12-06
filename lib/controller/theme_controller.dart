import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/data/theme_storage.dart';
import 'package:habit_tracker/services/firestore_service.dart';
import 'package:habit_tracker/utils/themeList.dart';
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
  final FirestoreService _firestoreService = FirestoreService();

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
      await _loadSavedTheme();
      // Try to sync with cloud if logged in
      if (_firestoreService.isUserLoggedIn) {
        _syncWithCloud();
      }
    } catch (e) {
      debugPrint('Error initializing theme: $e');
      _setDefaultTheme();
    }
  }

  Future<void> _loadSavedTheme() async {
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

  Future<void> _syncWithCloud() async {
    try {
      final cloudTheme = await _firestoreService.downloadTheme();
      if (cloudTheme != null) {
        // Apply cloud theme
        if (cloudTheme['themeName'] != null) {
          currentTheme.value = cloudTheme['themeName'];
        }
        
        if (cloudTheme['themeMode'] != null) {
          // Parse theme mode string
          String modeStr = cloudTheme['themeMode'];
          themeMode.value = _parseThemeMode(modeStr);
        }
        
        if (cloudTheme['useCustomBg'] != null) {
          useCustomBackground.value = cloudTheme['useCustomBg'];
        }
        
        if (cloudTheme['customBgColor'] != null) {
          customBackgroundColor.value = Color(cloudTheme['customBgColor']);
        }
        
        _buildBothThemes();
        _applyTheme();
        
        // Save to local storage to keep in sync
        await _saveThemeSettings(skipCloud: true);
      }
    } catch (e) {
      debugPrint('Error syncing theme from cloud: $e');
    }
  }

  ThemeMode _parseThemeMode(String modeStr) {
    if (modeStr == 'ThemeMode.dark') return ThemeMode.dark;
    if (modeStr == 'ThemeMode.light') return ThemeMode.light;
    return ThemeMode.system;
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

  Future<void> _saveThemeSettings({bool skipCloud = false}) async {
    try {
      await _storage.saveThemeSettings(
        themeName: currentTheme.value,
        mode: themeMode.value,
        useCustomBg: useCustomBackground.value,
        customBgColor:
            useCustomBackground.value ? customBackgroundColor.value : null,
      );
      
      if (!skipCloud && _firestoreService.isUserLoggedIn) {
        await _firestoreService.uploadTheme(
          currentTheme.value,
          themeMode.value,
          useCustomBackground.value,
          useCustomBackground.value ? customBackgroundColor.value : null,
        );
      }
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

    final isDarkTheme = ThemeUtils.isDarkTheme(themeData);
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
}
