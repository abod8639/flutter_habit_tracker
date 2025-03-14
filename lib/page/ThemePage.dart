import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/theme_controller.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    // bool isgrid = false;
    final ThemeController themeController = Get.find<ThemeController>();
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event.isKeyPressed(LogicalKeyboardKey.escape) ||
            event.isKeyPressed(LogicalKeyboardKey.backspace)) {
          Get.back();
        }

      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Theme Settings'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم وضع الثيم
              // _buildSectionTitle('Theme Mode'),
              // const SizedBox(height: 8),
              // _buildThemeModeSelector(themeController),

              // const SizedBox(height: 24),

              // قسم السمات المخصصة
              _buildSectionTitle('Custom Theme'),
              const SizedBox(height: 8),
              buildCustomThemeSelector(themeController),

              const SizedBox(height: 24),
           
              // قسم لون الخلفية
              // _buildSectionTitle('background color'),
              // const SizedBox(height: 8),
              // _buildBackgroundColorControls(context, themeController),
              const SizedBox(height: 24),

              // معاينة للثيم الحالي
              // _buildThemePreview(themeController),
            ],
          ),
        ),
      ),
    );
  }

  // عنوان كل قسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
/*
  // منتقي وضع الثيم (فاتح/داكن/تلقائي)
  Widget _buildThemeModeSelector(ThemeController controller) {
    return Obx(
      () => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ThemeMode>(
              isExpanded: true,
              value: controller.themeMode.value,
              icon: const Icon(Icons.brightness_4),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_5),
                      const SizedBox(width: 16),
                      const Text('Light'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_3),
                      const SizedBox(width: 16),
                      const Text('Dark'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_auto),
                      const SizedBox(width: 16),
                      const Text('Auto'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.changeThemeMode(value);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
*/

  // منتقي السمة المخصصة
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
              icon: Builder(

                builder: (context) {
                  return Icon(
                    color: Theme.of(context).primaryColor,
                    Icons.palette,
                  );
                },
              ),
              items:
                  controller.availableThemes
                      .map(
                        (themeName) => DropdownMenuItem(
                
                          value: themeName,
                          child: Row(
                            children: [
                              // اسم السمة بشكل مناسب
                              // SizedBox(width: 10),
                              Expanded(
                                child: Text(_formatThemeName(themeName)),
                              ),
                              SizedBox(width: 15),

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color:
                                      ThemeController
                                          .themeColors[themeName]!['primary'],
                                ),
                                width: 12,
                                height: 12,
                              ),
                              SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color:
                                      ThemeController
                                          .themeColors[themeName]!['secondary'],
                                ),
                                width: 12,
                                height: 12,
                              ),
                              SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color:
                                      ThemeController
                                          .themeColors[themeName]!['background'],
                                ),
                                width: 12,
                                height: 12,
                              ),
                              SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color:
                                      ThemeController
                                          .themeColors[themeName]!['surface'],
                                ),
                                width: 12,
                                height: 12,
                              ),
                              SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color:
                                      ThemeController
                                          .themeColors[themeName]!['onPrimary'],
                                ),
                                width: 12,
                                height: 12,
                              ),
                              SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color:
                                      ThemeController
                                          .themeColors[themeName]!['onSecondary'],
                                ),
                                width: 12,
                                height: 12,
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      )
                      .toList(),
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

  /*
  // التحكم بلون الخلفية المخصص
  Widget _buildBackgroundColorControls(
    BuildContext context,
    ThemeController controller,
  ) {
    return Obx(
      () => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // زر لعرض منتقي الألوان
              ElevatedButton.icon(
                onPressed: () => _showColorPicker(context, controller),
                icon: const Icon(Icons.color_lens),
                label: const Text('change background color'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // عرض مربع اللون الحالي
              Row(
                children: [
                  const Text('Color'),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showColorPicker(context, controller),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            controller.useCustomBackground.value
                                ? controller.customBackgroundColor.value
                                : ThemeController.themeColors[controller
                                    .currentTheme
                                    .value]!['background'],
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // زر إعادة التعيين
              TextButton.icon(
                
                onPressed:
                    controller.useCustomBackground.value
                        ? controller.resetBackgroundColor
                        : null,
                icon: const Icon(Icons.refresh),
                label:  Text(
                  style: TextStyle(color: Colors.redAccent ),
                  'Reset Background Color'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // معاينة للثيم الحالي
  Widget _buildThemePreview(ThemeController controller) {
    return Obx(() {
      final themeInfo = controller.getCurrentThemeInfo();
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The name of Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      ThemeController.themeColors[controller
                          .currentTheme
                          .value]!['primary'],
                ),
              ),
              const Divider(),
              _buildThemeInfoItem(
                'Name',
                _formatThemeName(themeInfo['name'] ?? ''),
              ),
              _buildThemeInfoItem(
                'وضع السمة',
                _formatThemeMode(themeInfo['mode'] ?? ''),
              ),

              _buildThemeInfoItem(
                'custom theme color',
                controller.useCustomBackground.value ? 'true' : 'false',
              ),

              const SizedBox(height: 10),

              // أمثلة لعناصر واجهة المستخدم بالثيم الحالي
            ],
          ),
        ),
      );
    });
  }


  // عنصر معلومات في معاينة الثيم
  Widget _buildThemeInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }


  // إظهار منتقي الألوان
  void _showColorPicker(BuildContext context, ThemeController controller) {
    Color pickerColor =
        controller.useCustomBackground.value
            ? controller.customBackgroundColor.value
            : ThemeController.themeColors[controller
                .currentTheme
                .value]!['background']!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختر لون الخلفية'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              showLabel: true,
              pickerAreaBorderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.changeBackgroundColor(pickerColor);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
*/

  // تنسيق اسم الثيم ليكون أكثر قابلية للقراءة
  String _formatThemeName(String name) {
    if (name.isEmpty) return '';
    // تحويل اسم مثل "midnight_blue" إلى "Midnight Blue"
    return name
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
/*
  // تنسيق وضع الثيم إلى نص مفهوم
  String _formatThemeMode(String mode) {
    if (mode.contains('light')) return 'فاتح';
    if (mode.contains('dark')) return 'داكن';
    if (mode.contains('system')) return 'تلقائي';
    return mode;
  }
*/


}
