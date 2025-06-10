import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/services/lang_storage.dart';

class Langcontroller extends GetxController {
  late final LangStorage _storage;
  var language = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      // Initialize storage
      _storage = await LangStorage.init();

      // Load saved language
      final savedLang = _storage.getCurrentLanguage();
      language.value = savedLang;

      // Update app locale
      Get.updateLocale(Get.locale ?? const Locale('en'));
    } catch (e) {
      debugPrint('Error initializing language controller: $e');
      // Fallback to default language
      language.value = LangStorage.defaultLanguage;
    }
  }

  Future<void> changeLanguage(String lang) async {
    try {
      // Save to storage
      await _storage.saveLanguage(lang);

      // Update observable
      language.value = lang;

      // Update app locale
      Get.updateLocale(Locale(lang));
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }
}
