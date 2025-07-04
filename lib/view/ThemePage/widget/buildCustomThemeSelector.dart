import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/ThemeController.Getx.dart';
import 'package:habit_tracker/utils/themeList.dart';
import 'package:habit_tracker/view/ThemePage/widget/buildThemeColorPreview.dart';

Widget buildCustomThemeSelector() {
  final ThemeController themeController = Get.put(ThemeController());
  return Builder(
    builder: (context) {
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
                icon: Icon(Icons.palette, color: Get.theme.primaryColor),
                items:
                    themeController.availableThemes.map((themeName) {
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
                    themeController.changeCustomTheme(value);
                  }
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

String formatThemeName(String name) {
  return name.split('_').map((word) => word.capitalizeFirst!).join(' ');
}
