import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/theme/data/datasources/themeList.dart';
import '../widgets/custom_theme_selector.dart';
import '../widgets/section_title.dart';
import '../widgets/theme_color_preview.dart';
import '../controllers/theme_controller.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyboardShortCutsPages(event),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            color: Theme.of(context).colorScheme.onSurface,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: Text(
            S.current.themepagetitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: S.current.themepage),
              const SizedBox(height: 8),
              const CustomThemeSelector(),
              const SizedBox(height: 24),
              
              const SectionTitle(title: 'Preview'),
              const SizedBox(height: 16),
              
              Obx(() {
                final currentTheme = themeController.currentTheme.value;
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _formatThemeName(currentTheme),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          ThemeColorPreview(
                            themeName: currentTheme,
                            themeColors: themeColors,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPreviewItem(context, 'Primary Color', Theme.of(context).primaryColor),
                      _buildPreviewItem(context, 'Secondary Color', Theme.of(context).colorScheme.secondary),
                      _buildPreviewItem(context, 'Background Color', Theme.of(context).scaffoldBackgroundColor),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewItem(BuildContext context, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatThemeName(String name) {
    return name.split('_').map((word) => word.capitalizeFirst!).join(' ');
  }
}
