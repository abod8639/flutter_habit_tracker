import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/services/firestore_service.dart';
import 'package:habit_tracker/data/habit_repository.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // Observable state
  final Rx<SyncStatus> syncStatus = SyncStatus.idle.obs;
  final RxBool isAutoSyncEnabled = true.obs;
  final Rx<DateTime?> lastSyncTime = Rx<DateTime?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLastSyncTime();
  }

  // Load last sync time from Firestore
  Future<void> _loadLastSyncTime() async {
    try {
      final time = await _firestoreService.getLastSyncTime();
      lastSyncTime.value = time;
    } catch (e) {
      debugPrint('Error loading last sync time: $e');
    }
  }

  // Manual sync
  Future<List<HabitModel>?> manualSync(List<HabitModel> localHabits) async {
    if (!_firestoreService.isUserLoggedIn) {
      Get.snackbar(
        S.current.error,
        S.current.loginRequired,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    try {
      syncStatus.value = SyncStatus.syncing;
      errorMessage.value = '';

      List<String> localTombstones = [];
      if (Get.isRegistered<HabitRepository>()) {
        localTombstones = Get.find<HabitRepository>().getLocalTombstones();
      }

      final mergedHabits = await _firestoreService.syncHabits(
        localHabits,
        localTombstones: localTombstones,
      );

      if (Get.isRegistered<HabitRepository>()) {
        Get.find<HabitRepository>().clearLocalTombstones();
      }

      lastSyncTime.value = DateTime.now();
      syncStatus.value = SyncStatus.success;

      Get.snackbar(
        S.current.success,
        S.current.syncSuccess,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return mergedHabits;
    } catch (e) {
      syncStatus.value = SyncStatus.error;
      errorMessage.value = e.toString();

      Get.snackbar(
        S.current.error,
        '${S.current.syncFailed}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );

      return null;
    }
  }

  // Auto sync (called on app start if logged in)
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

      final mergedHabits = await _firestoreService.syncHabits(
        localHabits,
        localTombstones: localTombstones,
      );

      if (Get.isRegistered<HabitRepository>()) {
        Get.find<HabitRepository>().clearLocalTombstones();
      }

      lastSyncTime.value = DateTime.now();
      syncStatus.value = SyncStatus.success;

      return mergedHabits;
    } catch (e) {
      syncStatus.value = SyncStatus.error;
      errorMessage.value = e.toString();
      debugPrint('Auto sync failed: $e');
      return null;
    }
  }

  // Upload habits to cloud
  Future<void> uploadHabits(List<HabitModel> habits) async {
    if (!_firestoreService.isUserLoggedIn) return;

    try {
      await _firestoreService.uploadHabits(habits);
      lastSyncTime.value = DateTime.now();
    } catch (e) {
      debugPrint('Error uploading habits: $e');
    }
  }

  // Download habits from cloud
  Future<List<HabitModel>?> downloadHabits() async {
    if (!_firestoreService.isUserLoggedIn) return null;

    try {
      syncStatus.value = SyncStatus.syncing;

      final habits = await _firestoreService.downloadHabits();

      lastSyncTime.value = DateTime.now();
      syncStatus.value = SyncStatus.success;

      return habits;
    } catch (e) {
      syncStatus.value = SyncStatus.error;
      errorMessage.value = e.toString();
      return null;
    }
  }

  // Delete habit from cloud
  Future<void> deleteHabit(String habitId) async {
    if (!_firestoreService.isUserLoggedIn) return;

    try {
      await _firestoreService.deleteHabit(habitId);
    } catch (e) {
      debugPrint('Error deleting habit from cloud: $e');
    }
  }

  // Upload habit history
  Future<void> uploadHabitHistory(String date, String completionRate) async {
    if (!_firestoreService.isUserLoggedIn) return;

    try {
      await _firestoreService.uploadHabitHistory(date, completionRate);
    } catch (e) {
      debugPrint('Error uploading habit history: $e');
    }
  }

  // Toggle auto sync
  void toggleAutoSync(bool value) {
    isAutoSyncEnabled.value = value;
  }

  // Get sync status message
  String get syncStatusMessage {
    switch (syncStatus.value) {
      case SyncStatus.idle:
        return lastSyncTime.value != null
            ? '${S.current.lastSync}: ${_formatTime(lastSyncTime.value!)}'
            : S.current.notSyncedYet;
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

    if (difference.inMinutes < 1) {
      return S.current.justNow;
    } else if (difference.inHours < 1) {
      return S.current.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return S.current.hoursAgo(difference.inHours);
    } else {
      return S.current.daysAgo(difference.inDays);
    }
  }

  // Check if user is logged in
  bool get isUserLoggedIn => _firestoreService.isUserLoggedIn;
}
