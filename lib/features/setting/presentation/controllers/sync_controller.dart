import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/data/habit_repository.dart';
import '../../domain/usecases/sync_habits_usecase.dart';
import '../../domain/usecases/get_last_sync_time_usecase.dart';
import 'package:habit_tracker/services/firestore_service.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncController extends GetxController {
  final SyncHabitsUseCase _syncHabitsUseCase = Get.find();
  final GetLastSyncTimeUseCase _getLastSyncTimeUseCase = Get.find();
  final FirestoreService _firestoreService = FirestoreService();

  final Rx<SyncStatus> syncStatus = SyncStatus.idle.obs;
  final RxBool isAutoSyncEnabled = true.obs;
  final Rx<DateTime?> lastSyncTime = Rx<DateTime?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLastSyncTime();
  }

  Future<void> _loadLastSyncTime() async {
    final result = await _getLastSyncTimeUseCase();
    result.fold(
      (failure) => debugPrint('Error loading last sync time: ${failure.message}'),
      (time) => lastSyncTime.value = time,
    );
  }

  Future<List<HabitModel>?> manualSync(List<HabitModel> localHabits) async {
    if (!_firestoreService.isUserLoggedIn) {
      Get.snackbar(S.current.error, S.current.loginRequired, snackPosition: SnackPosition.BOTTOM);
      return null;
    }

    try {
      syncStatus.value = SyncStatus.syncing;
      errorMessage.value = '';

      List<String> localTombstones = [];
      if (Get.isRegistered<HabitRepository>()) {
        localTombstones = Get.find<HabitRepository>().getLocalTombstones();
      }

      final result = await _syncHabitsUseCase(localHabits, localTombstones: localTombstones);

      return result.fold(
        (failure) {
          syncStatus.value = SyncStatus.error;
          errorMessage.value = failure.message;
          Get.snackbar(S.current.error, '${S.current.syncFailed}: ${failure.message}', snackPosition: SnackPosition.BOTTOM);
          return null;
        },
        (mergedHabits) {
          if (Get.isRegistered<HabitRepository>()) {
            Get.find<HabitRepository>().clearLocalTombstones();
          }
          lastSyncTime.value = DateTime.now();
          syncStatus.value = SyncStatus.success;
          Get.snackbar(S.current.success, S.current.syncSuccess, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
          return mergedHabits;
        }
      );
    } catch (e) {
      syncStatus.value = SyncStatus.error;
      errorMessage.value = e.toString();
      return null;
    }
  }

  Future<List<HabitModel>?> autoSync(List<HabitModel> localHabits) async {
    if (!isAutoSyncEnabled.value || !_firestoreService.isUserLoggedIn) {
      return null;
    }

    try {
      syncStatus.value = SyncStatus.syncing;

      List<String> localTombstones = [];
      if (Get.isRegistered<HabitRepository>()) {
        localTombstones = Get.find<HabitRepository>().getLocalTombstones();
      }

      final result = await _syncHabitsUseCase(localHabits, localTombstones: localTombstones);

      return result.fold(
        (failure) {
          syncStatus.value = SyncStatus.error;
          errorMessage.value = failure.message;
          return null;
        },
        (mergedHabits) {
          if (Get.isRegistered<HabitRepository>()) {
            Get.find<HabitRepository>().clearLocalTombstones();
          }
          lastSyncTime.value = DateTime.now();
          syncStatus.value = SyncStatus.success;
          return mergedHabits;
        }
      );
    } catch (e) {
      syncStatus.value = SyncStatus.error;
      errorMessage.value = e.toString();
      return null;
    }
  }

  void toggleAutoSync(bool value) {
    isAutoSyncEnabled.value = value;
  }

  String get syncStatusMessage {
    switch (syncStatus.value) {
      case SyncStatus.idle:
        return lastSyncTime.value != null ? '${S.current.lastSync}: ${_formatTime(lastSyncTime.value!)}' : S.current.notSyncedYet;
      case SyncStatus.syncing:
        return S.current.syncing;
      case SyncStatus.success:
        return S.current.syncSuccess;
      case SyncStatus.error:
        return S.current.syncFailed;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return S.current.justNow;
    if (difference.inHours < 1) return S.current.minutesAgo(difference.inMinutes);
    if (difference.inDays < 1) return S.current.hoursAgo(difference.inHours);
    return S.current.daysAgo(difference.inDays);
  }

  bool get isUserLoggedIn => _firestoreService.isUserLoggedIn;
}
