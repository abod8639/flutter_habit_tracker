import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/delete_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/edit_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_heatmap_data_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/is_user_logged_in_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reorder_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/toggle_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reset_daily_habits_usecase.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
import 'package:habit_tracker/functions/check_and_reset_habits.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';

class HabitController extends GetxController {
  // Use Cases
  final GetHabitsUseCase _getHabitsUseCase = Get.find();
  final AddHabitUseCase _addHabitUseCase = Get.find();
  final EditHabitUseCase _editHabitUseCase = Get.find();
  final DeleteHabitUseCase _deleteHabitUseCase = Get.find();
  final ToggleHabitUseCase _toggleHabitUseCase = Get.find();
  final ReorderHabitsUseCase _reorderHabitsUseCase = Get.find();
  final GetHeatmapDataUseCase _getHeatmapDataUseCase = Get.find();
  final IsUserLoggedInUseCase _isUserLoggedInUseCase = Get.find();
  final ResetDailyHabitsUseCase _resetDailyHabitsUseCase = Get.find();

  // State
  final RxList<HabitEntity> habits = <HabitEntity>[].obs;
  final RxMap<DateTime, int> heatmapDateSet = <DateTime, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isInitialized = false.obs;

  // UI State
  final TextEditingController habitTextController = TextEditingController();
  final RxList<String> selectedHabitIds = <String>[].obs;
  bool get isSelectionMode => selectedHabitIds.isNotEmpty;

  // Internal
  Timer? _resetCheckTimer;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _initialize();
    _setupAuthListener();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Perform initial reset check
      await _resetDailyHabitsUseCase();

      await _loadHabits();
      await _loadHeatmap();

      // Trigger sync if user is already logged in
      if (isUserLoggedIn()) {
        _syncOnLogin();
      }

      _setupHabitResetChecking();

      isInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Initialization failed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null && isInitialized.value) {
        _syncOnLogin();
      }
    });
  }

  Future<void> _syncOnLogin() async {
    if (!Get.isRegistered<SyncController>()) return;
    final syncController = Get.find<SyncController>();
    
    final result = await syncController.autoSync(habits.map((e) => HabitModel.fromEntity(e)).toList());
    if (result != null) {
      await refreshData();
    }
  }

  Future<void> _loadHabits() async {
    final result = await _getHabitsUseCase();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (loadedHabits) => habits.assignAll(loadedHabits),
    );
  }

  Future<void> _loadHeatmap() async {
    final result = await _getHeatmapDataUseCase();
    result.fold(
      (failure) => null,
      (data) => heatmapDateSet.assignAll(data),
    );
  }

  void _setupHabitResetChecking() {
    _resetCheckTimer?.cancel();
    _resetCheckTimer = Timer.periodic(const Duration(minutes: 15), (_) => checkAndResetHabits());
  }

  String getStartDay() {
    final box = Hive.box(HabitStorage.boxName);
    String storedStartDay = box.get(HabitStorage.startDayKey, defaultValue: "");
    
    // If we have heatmap data, find the earliest date
    if (heatmapDateSet.isNotEmpty) {
      DateTime minDate = heatmapDateSet.keys.reduce((a, b) => a.isBefore(b) ? a : b);
      String minDateStr = convertDateTimeToString(minDate);
      
      if (storedStartDay.isEmpty) return minDateStr;
      
      // Return the earlier of the two
      try {
        DateTime storedDate = createDateTimeObject(storedStartDay);
        return minDate.isBefore(storedDate) ? minDateStr : storedStartDay;
      } catch (e) {
        return minDateStr;
      }
    }
    
    return storedStartDay;
  }

  void incrementDayCount() {
    final box = Hive.box(HabitStorage.boxName);
    int dayCount = box.get(HabitStorage.dayCountKey) ?? 1;
    box.put(HabitStorage.dayCountKey, dayCount + 1);
  }

  // --- Public Actions ---

  Future<void> addHabit(String name) async {
    if (name.trim().isEmpty) return;
    
    final result = await _addHabitUseCase(name);
    result.fold(
      (failure) => _showError(failure.message),
      (_) async {
        habitTextController.clear();
        await refreshData();
      },
    );
  }

  Future<void> editHabit(String id, String newName) async {
    if (newName.trim().isEmpty) return;

    final result = await _editHabitUseCase(id, newName);
    result.fold(
      (failure) => _showError(failure.message),
      (_) => _loadHabits(),
    );
  }

  Future<void> deleteHabit(String id) async {
    final result = await _deleteHabitUseCase(id);
    result.fold(
      (failure) => _showError(failure.message),
      (_) async {
        await refreshData();
      },
    );
  }

  Future<void> toggleHabit(String id, bool value) async {
    final result = await _toggleHabitUseCase(id, value);
    result.fold(
      (failure) => _showError(failure.message),
      (_) async {
        await refreshData();
      },
    );
  }

  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    final result = await _reorderHabitsUseCase(oldIndex, newIndex);
    result.fold(
      (failure) => _showError(failure.message),
      (_) => _loadHabits(),
    );
  }

  // --- Multi-selection ---

  void toggleHabitSelection(String id) {
    if (selectedHabitIds.contains(id)) {
      selectedHabitIds.remove(id);
    } else {
      selectedHabitIds.add(id);
    }
  }

  void clearSelection() => selectedHabitIds.clear();

  Future<void> deleteSelectedHabits() async {
    for (final id in List.from(selectedHabitIds)) {
      await deleteHabit(id);
    }
    clearSelection();
  }

  Future<void> updateSelectedHabitsColor(Color color) async {
    // This logic would need to be moved to a Use Case for full Clean Arch compliance
    // For now, staying with the existing simple implementation
    clearSelection();
    await _loadHabits();
  }

  Future<void> refreshData() async {
    await _loadHabits();
    await _loadHeatmap();
  }

  void _showError(String message) {
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }

  bool isUserLoggedIn() => _isUserLoggedInUseCase();

  @override
  void onClose() {
    _authSubscription?.cancel();
    _resetCheckTimer?.cancel();
    habitTextController.dispose();
    super.onClose();
  }
}
