import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/theme/presentation/controllers/theme_controller.dart';
import 'package:habit_tracker/utils/themeList.dart';
import 'theme_color_preview.dart';

class CustomThemeSelector extends StatelessWidget {
  const CustomThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Obx(
      () => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              autofocus: true,
              isExpanded: true,
              value: themeController.currentTheme.value,
              icon: Icon(Icons.palette, color: Theme.of(context).primaryColor),
              items: themeController.availableThemes.map((themeName) {
                return DropdownMenuItem(
                  value: themeName,
                  child: Row(
                    children: [
                      Expanded(child: Text(_formatThemeName(themeName))),
                      const SizedBox(width: 15),
                      ThemeColorPreview(
                        themeName: themeName,
                        themeColors: themeColors,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  themeController.changeCustomTheme(value);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatThemeName(String name) {
    return name.split('_').map((word) => word.capitalizeFirst!).join(' ');
  }
}
