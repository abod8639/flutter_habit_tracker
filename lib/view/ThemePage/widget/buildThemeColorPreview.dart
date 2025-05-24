import 'package:flutter/material.dart';

List<Widget> buildThemeColorPreview(String themeName, themeColors) {
  return [
    'primary',
    'secondary',
    'background',
    'surface',
    'onPrimary',
    'onSecondary',
  ].map((key) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: themeColors[themeName]?[key],
      ),
    );
  }).toList();
}
