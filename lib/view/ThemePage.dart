import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/themeList.dart';
import 'package:habit_tracker/controller/theme_controller.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        // Skip handling special keys like NumLock to avoid conflicts
        if (event.physicalKey == PhysicalKeyboardKey.numLock) {
          return;
        }

        if ((event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) ||
            (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace)) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Theme Settings'),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Custom Theme'),
              const SizedBox(height: 8),
              _buildCustomThemeSelector(themeController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCustomThemeSelector(ThemeController controller) {
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
                          Expanded(child: Text(_formatThemeName(themeName))),
                          const SizedBox(width: 15),
                          ..._buildThemeColorPreview(themeName),
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

  List<Widget> _buildThemeColorPreview(String themeName) {
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

  String _formatThemeName(String name) {
    return name.split('_').map((word) => word.capitalizeFirst!).join(' ');
  }
}
