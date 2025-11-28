import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsStorage {
  static const String boxName = 'settings_box';
  static const String _isNotificationEnabledKey = 'is_notification_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _hasSkippedLoginKey = 'has_skipped_login';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  bool get isNotificationEnabled =>
      _box.get(_isNotificationEnabledKey, defaultValue: false);

  Future<void> setNotificationEnabled(bool enabled) async {
    await _box.put(_isNotificationEnabledKey, enabled);
  }

  TimeOfDay? get notificationTime {
    final String? timeStr = _box.get(_notificationTimeKey);
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    await _box.put(_notificationTimeKey, '${time.hour}:${time.minute}');
  }

  bool get hasSkippedLogin =>
      _box.get(_hasSkippedLoginKey, defaultValue: false);

  Future<void> setSkippedLogin(bool skipped) async {
    await _box.put(_hasSkippedLoginKey, skipped);
  }
}
