import 'package:flutter/material.dart';

class ThemeModel {
  final String name;
  final Map<String, Color> colors;
  final bool isDarkOriented;

  const ThemeModel({
    required this.name,
    required this.colors,
    required this.isDarkOriented,
  });

  Color get primary => colors['primary']!;
  Color get secondary => colors['secondary']!;
  Color get background => colors['background']!;
  Color get surface => colors['surface']!;
  Color get error => colors['error']!;
  Color get onPrimary => colors['onPrimary']!;
  Color get onSecondary => colors['onSecondary']!;
}
