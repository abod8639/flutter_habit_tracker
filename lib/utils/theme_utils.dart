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

    final surfaceColor =
        forceDark && !isDarkTheme
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
      cardTheme: CardTheme(
        color: surfaceColor,
        shadowColor: colors['primary']!.withOpacity(0.3),
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
        fillColor: backgroundColor.withOpacity(0.8),
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
    final baseTextTheme =
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme;
    return baseTextTheme.apply(bodyColor: textColor, displayColor: textColor);
  }
}
