import 'package:flutter/material.dart';

class ThemeColorPreview extends StatelessWidget {
  final String themeName;
  final Map<String, Map<String, Color>> themeColors;

  const ThemeColorPreview({
    super.key,
    required this.themeName,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> colorKeys = [
      'primary',
      'secondary',
      'background',
      'surface',
      'onPrimary',
      'onSecondary',
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colorKeys.map((key) {
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: themeColors[themeName]?[key],
          ),
        );
      }).toList(),
    );
  }
}
