import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/themeList.dart';
import 'package:habit_tracker/controller/theme_controller.dart';
import 'package:habit_tracker/view/ThemePage/widget/buildThemeColorPreview.dart';

Widget buildCustomThemeSelector(ThemeController controller) {
  return Obx(
    () => Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            autofocus: true,
            isExpanded: true,
            value: controller.currentTheme.value,
            icon: Icon(Icons.palette, color: Get.theme.primaryColor),
            items:
                controller.availableThemes.map((themeName) {
                  return DropdownMenuItem(
                    value: themeName,
                    child: Row(
                      children: [
                        Expanded(child: Text(formatThemeName(themeName))),
                        const SizedBox(width: 15),
                        ...buildThemeColorPreview(themeName, themeColors),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.changeCustomTheme(value);
              }
            },
          ),
        ),
      ),
    ),
  );
}

String formatThemeName(String name) {
  return name.split('_').map((word) => word.capitalizeFirst!).join(' ');
}
