import 'dart:math' as Math;

import 'package:flutter/material.dart';

class ThemeUtils {
  static Color getContrastColor(Color backgroundColor) {
    return _shouldUseDarkText(backgroundColor) ? Colors.black : Colors.white;
  }

  static bool _shouldUseDarkText(Color backgroundColor) {
    final brightness =
        (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;
    return brightness > 138;
  }

  static Color adjustBrightness(Color color, double brightness) {
    assert(
      brightness >= 0 && brightness <= 1,
      'Brightness must be between 0 and 1',
    );
    return HSLColor.fromColor(color).withLightness(brightness).toColor();
  }

  static ThemeData buildThemeData({
    required bool forceDark,
    required Map<String, Color> colors,
    required bool isDarkTheme,
    Color? customBackground,
  }) {
    final brightness = forceDark ? Brightness.dark : Brightness.light;

    // Determine background and surface colors
    final backgroundColor =
        customBackground ??
        (forceDark && !isDarkTheme
            ? adjustBrightness(colors['background']!, 0.2)
            : colors['background']!);

    final surfaceColor = forceDark && !isDarkTheme
        ? adjustBrightness(colors['surface']!, 0.2)
        : colors['surface']!;

    final onSurfaceColor = getContrastColor(surfaceColor);
    final onBackgroundColor = getContrastColor(backgroundColor);

    return ThemeData(
      brightness: brightness,
      primaryColor: colors['primary'],
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors['primary']!,
        onPrimary: colors['onPrimary']!,
        secondary: colors['secondary']!,
        onSecondary: colors['onSecondary']!,
        error: colors['error']!,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors['primary'],
        foregroundColor: colors['onPrimary'],
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        shadowColor: colors['primary']!.withValues(alpha:0.3),
        elevation: 3,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors['secondary'],
        foregroundColor: colors['onSecondary'],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors['onPrimary'],
          backgroundColor: colors['primary'],
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return colors['primary']!;
          }
          return Colors.grey;
        }),
        checkColor: WidgetStateProperty.all(colors['onPrimary']),
      ),
      textTheme: _createTextTheme(brightness, onBackgroundColor),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: backgroundColor.withValues(alpha:0.8),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors['primary']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors['primary']!, width: 2),
        ),
      ),
    );
  }

  static TextTheme _createTextTheme(Brightness brightness, Color textColor) {
    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return baseTextTheme.apply(bodyColor: textColor, displayColor: textColor);
  }

  // New method to automatically detect if a theme is dark based on its colors
  static bool isDarkTheme(Map<String, dynamic> themeColors) {
    // Check if the theme explicitly defines if it's dark
    if (themeColors.containsKey('isDark')) {
      return themeColors['isDark'] == true;
    }

    // If not explicitly defined, analyze the colors to determine if it's dark
    // Get the primary or background color to analyze
    Color colorToAnalyze;

    if (themeColors.containsKey('backgroundColor')) {
      // If backgroundColor is available, use it
      colorToAnalyze = parseColor(themeColors['backgroundColor']);
    } else if (themeColors.containsKey('primaryColor')) {
      // Otherwise use primaryColor
      colorToAnalyze = parseColor(themeColors['primaryColor']);
    } else if (themeColors.containsKey('scaffoldBackgroundColor')) {
      // Or scaffoldBackgroundColor
      colorToAnalyze = parseColor(themeColors['scaffoldBackgroundColor']);
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
  static Color parseColor(dynamic colorValue) {
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
