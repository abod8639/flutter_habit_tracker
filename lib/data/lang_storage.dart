// Language storage constants and helpers
import 'package:hive/hive.dart';

class LangStorage {
  static const String boxName = "Lang_db";
  static const String languageKey = "CURRENT_LANGUAGE";
  static const String defaultLanguage = "en";

  final Box _box;

  LangStorage(this._box);

  static Future<LangStorage> init() async {
    final box = await Hive.openBox(boxName);
    return LangStorage(box);
  }

  String getCurrentLanguage() {
    return _box.get(languageKey, defaultValue: defaultLanguage);
  }

  Future<void> saveLanguage(String languageCode) async {
    await _box.put(languageKey, languageCode);
  }
}
