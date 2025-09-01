import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/functions/keyboardShortCutsPages.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/ThemePage/widget/buildCustomThemeSelector.dart';
import 'package:habit_tracker/view/ThemePage/widget/buildSectionTitle.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyboardShortCutsPages(event),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            color: Theme.of(context).colorScheme.onSurface,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          centerTitle: true,
          title: Text(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            S.current.themepagetitle,
          ),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionTitle(S.current.themepage),
              const SizedBox(height: 8),
              buildCustomThemeSelector(),
            ],
          ),
        ),
      ),
    );
  }
}

