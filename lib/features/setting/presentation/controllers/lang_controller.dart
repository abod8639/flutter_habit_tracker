import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/usecases/get_language_usecase.dart';
import '../../domain/usecases/save_language_usecase.dart';
import 'package:habit_tracker/data/lang_storage.dart';

class LangController extends GetxController {
  final GetLanguageUseCase _getLanguageUseCase = Get.find();
  final SaveLanguageUseCase _saveLanguageUseCase = Get.find();

  var language = Intl.getCurrentLocale().obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final result = await _getLanguageUseCase();
    result.fold(
      (failure) {
        debugPrint('Error loading language: ${failure.message}');
        language.value = LangStorage.defaultLanguage;
      },
      (langCode) {
        language.value = langCode;
        Get.updateLocale(Locale(langCode));
      },
    );
  }

  Future<void> changeLanguage(String lang) async {
    final result = await _saveLanguageUseCase(lang);
    result.fold(
      (failure) {
        debugPrint('Error saving language: ${failure.message}');
      },
      (_) {
        language.value = lang;
        Get.updateLocale(Locale(lang));
      },
    );
  }
}
