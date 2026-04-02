import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';

abstract class SettingLocalDataSource {
  Future<String> getLanguage();
  Future<void> saveLanguage(String languageCode);
  
  bool isNotificationEnabled();
  Future<void> setNotificationEnabled(bool enabled);
  
  TimeOfDay? getNotificationTime();
  Future<void> setNotificationTime(TimeOfDay time);

  DateTime? getLastSyncTime();
}

class SettingLocalDataSourceImpl implements SettingLocalDataSource {
  final Box _langBox;
  final Box _settingsBox;

  SettingLocalDataSourceImpl({
    required Box langBox,
    required Box settingsBox,
  }) : _langBox = langBox,
       _settingsBox = settingsBox;

  @override
  Future<String> getLanguage() async {
    return _langBox.get(LangStorage.languageKey, defaultValue: LangStorage.defaultLanguage);
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    await _langBox.put(LangStorage.languageKey, languageCode);
  }

  @override
  bool isNotificationEnabled() {
    return _settingsBox.get('is_notification_enabled', defaultValue: false);
  }

  @override
  Future<void> setNotificationEnabled(bool enabled) async {
    await _settingsBox.put('is_notification_enabled', enabled);
  }

  @override
  TimeOfDay? getNotificationTime() {
    final String? timeStr = _settingsBox.get('notification_time');
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Future<void> setNotificationTime(TimeOfDay time) async {
    await _settingsBox.put('notification_time', '${time.hour}:${time.minute}');
  }

  @override
  DateTime? getLastSyncTime() {
    // This depends on how last sync time is stored. 
    // Usually it's in the habit_box or settings_box.
    // Looking at SyncController, it gets it from FirestoreService.
    // But we might want to cache it locally too.
    return null; 
  }
}
