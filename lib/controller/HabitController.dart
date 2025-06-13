// habit_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/data/HabitStorage.dart';
import 'package:habit_tracker/data/habit_db.dart';
import 'package:habit_tracker/functions/HabitActions.dart';
import 'package:habit_tracker/functions/HabitUtils.dart';
import 'package:habit_tracker/models/date_time.dart';
import 'package:hive/hive.dart';

class HabitController extends GetxController {
  final Habitdb db = Habitdb();
  final TextEditingController habitTextController = TextEditingController();
  late final Box _myBox;
  Timer? _resetCheckTimer;
  RxInt dayCount = 1.obs;
  Rx<DateTime?> lastResetDate = Rx<DateTime?>(null);
  RxInt index = 0.obs;

  // Map to store habit completion history
  final Rx<Map<String, Map<DateTime, bool>>> habitHistoryMap =
      Rx<Map<String, Map<DateTime, bool>>>({});

  // Status indicators
  final RxBool isInitialized = false.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAsync();
  }

  /// Initialize the controller asynchronously
  Future<void> _initializeAsync() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get the Hive box
      _myBox = Hive.box(HabitStorage.boxName);

      // Initialize the database and load data
      await initializeBox(_myBox, db);

      // Initialize reactive variables
      _initializeReactiveState();

      // Check for habit reset
      _setupHabitResetChecking();

      isInitialized.value = true;
      debugPrint('✅ HabitController initialized successfully');
    } catch (e) {
      errorMessage.value = 'Failed to initialize: $e';
      debugPrint('❌ Error initializing HabitController: $e');

      // Try to recover
      _attemptRecovery();
    } finally {
      isLoading.value = false;
    }
  }

  /// Initialize reactive state variables
  void _initializeReactiveState() {
    // Load day count with a default value if not found
    dayCount.value =
        _myBox.get(HabitStorage.dayCountKey) ?? HabitStorage.defaultDayCount;

    // Load last reset date
    lastResetDate.value = getLastResetDate(_myBox);

    // Load habit history
    _loadHabitHistory();
  }

  /// Set up periodic checking for habit resets
  void _setupHabitResetChecking() {
    // Check immediately on startup
    checkAndResetHabits();

    // Then check periodically
    _resetCheckTimer?.cancel(); // Cancel any existing timer
    _resetCheckTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => checkAndResetHabits(),
    );

    debugPrint('🔄 Habit reset checking schedule established');
  }

  /// Attempt recovery from initialization errors
  void _attemptRecovery() {
    try {
      // Attempt to initialize with default values
      dayCount.value = HabitStorage.defaultDayCount;
      lastResetDate.value = DateTime.now();
      saveLastResetDate(_myBox, lastResetDate.value!);

      // Create default data
      db.createDefaultData();

      // Set up checking
      _setupHabitResetChecking();

      isInitialized.value = true;
      debugPrint('🔄 Recovery successful');
    } catch (e) {
      debugPrint('❌ Recovery failed: $e');
      errorMessage.value = 'Recovery failed: $e';
    }
  }

  /// Check if habits need to be reset for a new day
  void checkAndResetHabits() {
    try {
      if (shouldResetHabits(lastResetDate.value)) {
        debugPrint('🔄 Resetting habits for new day');

        // Save current state to history before reset
        final habits = db.todaysHabitList;
        final now = DateTime.now();
        final normalizedDate = DateTime(now.year, now.month, now.day);
        final currentHistory = Map<String, Map<DateTime, bool>>.from(
          habitHistoryMap.value,
        );
        final todayStr = convertDateTimeToString(normalizedDate);

        // Save each habit's current state to history
        for (var habit in habits) {
          final String habitName = habit[0];
          final bool isCompleted = habit[1];

          // Save to history map
          if (!currentHistory.containsKey(habitName)) {
            currentHistory[habitName] = {};
          }
          currentHistory[habitName]![normalizedDate] = isCompleted;

          // Save to database
          final String historyKey = "${habitName}_$todayStr";
          _myBox.put(historyKey, isCompleted);
        }
        habitHistoryMap.value = currentHistory;

        // Perform reset
        incrementDayCount();
        resetAllHabits(db);
        lastResetDate.value = DateTime.now();
        saveLastResetDate(_myBox, lastResetDate.value!);

        // Make sure all habits start as not completed for the new day
        final newDate = DateTime.now();
        final newNormalizedDate = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
        );
        for (var habit in habits) {
          final String habitName = habit[0];
          currentHistory[habitName]![newNormalizedDate] = false;
        }
        habitHistoryMap.value = currentHistory;
      }
    } catch (e) {
      debugPrint('❌ Error checking/resetting habits: $e');
    }
  }

  void incrementDayCount() {
    dayCount.value++;
    _myBox.put(HabitStorage.dayCountKey, dayCount.value);
  }

  void incrementDayManually() {
    // Increment the day count
    incrementDayCount();

    // Update last reset date
    lastResetDate.value = DateTime.now();
    saveLastResetDate(_myBox, lastResetDate.value!);

    // Update habit stats
    db.habitCalculate();
    db.loadHeatmap();

    update();

    // Show success message
    Get.snackbar(
      'Day Count Updated',
      'Day count is now: ${dayCount.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void manualReset() {
    Get.defaultDialog(
      title: 'Reset All Habits',
      middleText:
          'Are you sure you want to reset all habits? All habits will be marked as incomplete.',
      textConfirm: 'Reset',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        resetAllHabits(db);
        update();
        Get.back();
      },
    );
  }

  /// Load habit history from storage
  void _loadHabitHistory() {
    try {
      final Map<String, Map<DateTime, bool>> history = {};
      final habits = db.todaysHabitList;
      final startDate = createDateTimeObject(getStartDay());
      final today = DateTime.now();

      for (var habit in habits) {
        final String habitName = habit[0];
        final Map<DateTime, bool> habitData = {};

        for (
          var date = startDate;
          date.isBefore(today) || date.isAtSameMomentAs(today);
          date = date.add(const Duration(days: 1))
        ) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final String formattedDate = convertDateTimeToString(normalizedDate);
          final String historyKey = "${habitName}_$formattedDate";
          final bool? completed = _myBox.get(historyKey);
          if (completed != null) {
            habitData[normalizedDate] = completed;
          }
        }

        history[habitName] = habitData;
      }

      habitHistoryMap.value = history;
      debugPrint('📊 Loaded history for ${history.length} habits');
    } catch (e) {
      debugPrint('❌ Error loading habit history: $e');
      habitHistoryMap.value = {};
    }
  }

  @override
  void onClose() {
    _resetCheckTimer?.cancel();
    habitTextController.dispose();
    super.onClose();
  }

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000.0;
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600.0 &&
      MediaQuery.of(context).size.width < 1000.0;
  bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600.0;

  String getStartDay() {
    return _myBox.get(HabitStorage.startDayKey, defaultValue: "");
  }
}
