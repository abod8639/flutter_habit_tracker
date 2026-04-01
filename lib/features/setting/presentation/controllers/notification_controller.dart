import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/services/notification_service.dart';
import '../../domain/usecases/is_notification_enabled_usecase.dart';
import '../../domain/usecases/set_notification_enabled_usecase.dart';
import '../../domain/usecases/get_notification_time_usecase.dart';
import '../../domain/usecases/set_notification_time_usecase.dart';

class NotificationController extends GetxController {
  final IsNotificationEnabledUseCase _isNotificationEnabledUseCase = Get.find();
  final SetNotificationEnabledUseCase _setNotificationEnabledUseCase = Get.find();
  final GetNotificationTimeUseCase _getNotificationTimeUseCase = Get.find();
  final SetNotificationTimeUseCase _setNotificationTimeUseCase = Get.find();
  
  final NotificationService _notificationService = NotificationService();

  var isNotificationEnabled = false.obs;
  var notificationTime = Rxn<TimeOfDay>();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabledResult = await _isNotificationEnabledUseCase();
    enabledResult.fold(
      (failure) => debugPrint('Error loading notification status: ${failure.message}'),
      (enabled) => isNotificationEnabled.value = enabled,
    );

    final timeResult = await _getNotificationTimeUseCase();
    timeResult.fold(
      (failure) => debugPrint('Error loading notification time: ${failure.message}'),
      (time) => notificationTime.value = time,
    );
  }

  Future<void> toggleNotification(bool enabled) async {
    isNotificationEnabled.value = enabled;
    final result = await _setNotificationEnabledUseCase(enabled);
    
    result.fold(
      (failure) => debugPrint('Error saving notification status: ${failure.message}'),
      (_) async {
        if (enabled) {
          if (notificationTime.value != null) {
            await _scheduleNotification(notificationTime.value!);
          } else {
            const defaultTime = TimeOfDay(hour: 9, minute: 0);
            await setNotificationTime(defaultTime);
          }
        } else {
          await _notificationService.cancelAllNotifications();
        }
      },
    );
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    notificationTime.value = time;
    final result = await _setNotificationTimeUseCase(time);

    result.fold(
      (failure) => debugPrint('Error saving notification time: ${failure.message}'),
      (_) async {
        if (isNotificationEnabled.value) {
          await _scheduleNotification(time);
        }
      },
    );
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    await _notificationService.cancelAllNotifications();
    await _notificationService.scheduleDailyNotification(
      id: 0,
      title: 'Habit Tracker',
      body: 'Time to check your habits!',
      time: time,
    );
  }
}
