import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/services/firestore_service.dart';

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
        'يرجى تسجيل الدخول أولاً',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    try {
      syncStatus.value = SyncStatus.syncing;
      errorMessage.value = '';

      final mergedHabits = await _firestoreService.syncHabits(localHabits);
      
      lastSyncTime.value = DateTime.now();
      syncStatus.value = SyncStatus.success;

      Get.snackbar(
        'نجح',
        'تمت المزامنة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return mergedHabits;
    } catch (e) {
      syncStatus.value = SyncStatus.error;
      errorMessage.value = e.toString();
      
      Get.snackbar(
        S.current.error,
        'فشلت المزامنة: $e',
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
      
      final mergedHabits = await _firestoreService.syncHabits(localHabits);
      
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
            ? 'آخر مزامنة: ${_formatTime(lastSyncTime.value!)}'
            : 'لم تتم المزامنة بعد';
      case SyncStatus.syncing:
        return 'جاري المزامنة...';
      case SyncStatus.success:
        return 'تمت المزامنة بنجاح';
      case SyncStatus.error:
        return 'فشلت المزامنة';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  // Check if user is logged in
  bool get isUserLoggedIn => _firestoreService.isUserLoggedIn;
}
