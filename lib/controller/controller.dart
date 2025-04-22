// habit_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitActions.dart';
import 'package:habit_tracker/data/habit_db.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/models/HabitUtils.dart';
import 'package:habit_tracker/services/HamitStorage.dart';
import 'package:habit_tracker/view/widget/myalartD.dart';
import 'package:hive/hive.dart';

class HabitController extends GetxController {
  final Habitdb db = Habitdb();
  final TextEditingController habitTextController = TextEditingController();
  late final Box _myBox;
  Timer? _resetCheckTimer;
  RxInt dayCount = 1.obs;
  Rx<DateTime?> lastResetDate = Rx<DateTime?>(null);
  RxInt index = 0.obs;

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
        incrementDayCount();
        resetAllHabits(db);
        lastResetDate.value = DateTime.now();
        saveLastResetDate(_myBox, lastResetDate.value!);
      }
    } catch (e) {
      debugPrint('❌ Error checking/resetting habits: $e');
    }
  }

  void incrementDayCount() {
    dayCount.value++;
    _myBox.put(HabitStorage.dayCountKey, dayCount.value);
  }

  void addHabit(BuildContext context) {
    habitTextController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return Myalartd(
          hintText: 'Add new Habit...',
          controller: habitTextController,
          onSave: () {
            final String habitName = habitTextController.text.trim();
            if (habitName.isNotEmpty) {
              db.addHabit(habitName);
              update();
              Navigator.of(context).pop();
            } else {
              Get.snackbar(
                'Error',
                'Habit name cannot be empty',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withOpacity(0.7),
                colorText: Colors.white,
              );
            }
          },
        );
      },
    );
  }

  void editHabit(int index, BuildContext context) {
    HabitModel? habit = db.getHabitByIndex(index);
    if (habit == null) return;

    habitTextController.text = habit.name;
    showDialog(
      context: context,
      builder: (context) {
        return Myalartd(
          hintText: 'Edit This Habit',
          controller: habitTextController,
          onSave: () {
            final String habitName = habitTextController.text.trim();
            if (habitName.isNotEmpty) {
              db.editHabitByIndex(index, habitName);
              update();
              Navigator.of(context).pop();
            } else {
              Get.snackbar(
                'Error',
                'The field can\'t be empty',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withOpacity(0.7),
                colorText: Colors.white,
              );
            }
          },
        );
      },
    );
  }

  void deleteHabit(int index, BuildContext context) {
    if (db.getHabitByIndex(index) == null) return;

    Get.defaultDialog(
      buttonColor: Theme.of(context).colorScheme.secondary,
      cancelTextColor: Theme.of(context).colorScheme.primary,
      confirmTextColor: Theme.of(context).colorScheme.error,
      title: 'Delete Habit',
      middleText: 'Are you sure you want to delete this habit?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      onCancel: () => Get.back(),
      onConfirm: () {
        db.deleteHabitByIndex(index);
        update();
        Get.back();
      },
    );
  }

  void toggleHabit(bool? value, int index) {
    if (db.getHabitByIndex(index) == null) return;
    db.toggleHabitByIndex(index, value ?? false);
    update();
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
