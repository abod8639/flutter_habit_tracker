import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/services/notification_service.dart';

class NotificationController extends GetxController {
  final SettingsStorage _settingsStorage = SettingsStorage();
  final NotificationService _notificationService = NotificationService();

  var isNotificationEnabled = false.obs;
  var notificationTime = Rxn<TimeOfDay>();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsStorage.init();
    isNotificationEnabled.value = _settingsStorage.isNotificationEnabled;
    notificationTime.value = _settingsStorage.notificationTime;
  }

  Future<void> toggleNotification(bool enabled) async {
    isNotificationEnabled.value = enabled;
    await _settingsStorage.setNotificationEnabled(enabled);

    if (enabled) {
      if (notificationTime.value != null) {
        await _scheduleNotification(notificationTime.value!);
      } else {
        // Default time if none set (e.g., 9:00 AM)
        const defaultTime = TimeOfDay(hour: 9, minute: 0);
        await setNotificationTime(defaultTime);
      }
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    notificationTime.value = time;
    await _settingsStorage.setNotificationTime(time);

    if (isNotificationEnabled.value) {
      await _scheduleNotification(time);
    }
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    await _notificationService
        .cancelAllNotifications(); // Cancel existing before scheduling new
    await _notificationService.scheduleDailyNotification(
      id: 0,
      title: 'Habit Tracker',
      body: 'Time to check your habits!',
      time: time,
    );
  }
}
