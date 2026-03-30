import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/sync_controller.dart';
import 'package:habit_tracker/data/habit_storage.dart';
import 'package:habit_tracker/data/habit_repository.dart';
import 'package:habit_tracker/functions/check_and_reset_habits.dart';
import 'package:habit_tracker/models/date_time.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:hive/hive.dart';

class HabitController extends GetxController {
  final HabitRepository db = HabitRepository();
  final TextEditingController habitTextController = TextEditingController();
  late final Box myBox;
  Timer? _resetCheckTimer;
  RxInt dayCount = 1.obs;
  RxInt streak = 1.obs;
  Rx<DateTime?> lastResetDate = Rx<DateTime?>(null);
  RxInt index = 0.obs;

  // Multi-selection state
  final RxList<String> selectedHabitIds = <String>[].obs;
  bool get isSelectionMode => selectedHabitIds.isNotEmpty;

  final Rx<Map<String, Map<DateTime, bool>>> habitHistoryMap =
      Rx<Map<String, Map<DateTime, bool>>>({});

  // Status indicators
  final RxBool isInitialized = false.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Sync state
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    // Ensure we don't initialize twice or in wrong zone
    if (!isInitialized.value) {
      _initializeAsync();
      _setupAuthListener();
    }
  }

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
       if (user != null) {
          // Wait for local DB to initialize before fetching from cloud
          while (!isInitialized.value) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          _syncOnLogin();
       }
    });
  }

  Future<void> _syncOnLogin() async {
    try {
      if (!Get.isRegistered<SyncController>()) return;
      
      final syncController = Get.find<SyncController>();
      
      isLoading.value = true;
      errorMessage.value = '';

      // Attempt to load remote data overriding local, using smart merge
      final serverHabits = await syncController.autoSync(db.todaysHabitList);
      if (serverHabits != null) {
        updateHabits(serverHabits);
      }
    } catch (e) {
      debugPrint('Error syncing on login: $e');
      errorMessage.value = 'Failed to sync on login: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Initialize the controller asynchronously
  Future<void> _initializeAsync() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get the Hive box
      myBox = Hive.box(HabitStorage.boxName);

      // Initialize the database and load data
      await initializeBox(myBox, db);

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
        myBox.get(HabitStorage.dayCountKey) ?? HabitStorage.defaultDayCount;

    // Load last reset date
    lastResetDate.value = getLastResetDate(myBox);

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
      saveLastResetDate(myBox, lastResetDate.value!);

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

  void incrementDayCount() {
    dayCount.value++;
    myBox.put(HabitStorage.dayCountKey, dayCount.value);
  }

  /// Update habits from sync and refresh UI
  void updateHabits(List<HabitModel> newHabits) {
    debugPrint('💾 Sync: Persisting ${newHabits.length} habits to local storage...');
    db.todaysHabitList = newHabits;
    
    // Explicitly call updateData to save to Hive permanently
    db.updateData(); 
    
    update(); // Trigger GetBuilder rebuilds
    _loadHabitHistory();
  }

  /// Load habit history from storage
  void _loadHabitHistory() {
    try {
      final Map<String, Map<DateTime, bool>> history = {};
      final habits = db.todaysHabitList;
      final startDate = createDateTimeObject(getStartDay());
      final today = DateTime.now();

      for (var habit in habits) {
        final String habitName = habit.name;
        final Map<DateTime, bool> habitData = {};

        for (
          var date = startDate;
          date.isBefore(today) || date.isAtSameMomentAs(today);
          date = date.add(const Duration(days: 1))
        ) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final String formattedDate = convertDateTimeToString(normalizedDate);
          final String historyKey = "${habitName}_$formattedDate";
          final bool? completed = myBox.get(historyKey);
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
    _authSubscription?.cancel();
    _resetCheckTimer?.cancel();
    habitTextController.dispose();
    super.onClose();
  }

  // void reorderHabits(int oldIndex, int newIndex) {
  //   db.reorderHabits(oldIndex, newIndex);
  //   update();
  // }

  String getStartDay() {
    return myBox.get(HabitStorage.startDayKey, defaultValue: "");
  }

  // --- Multi-selection actions ---

  void toggleHabitSelection(String id) {
    if (selectedHabitIds.contains(id)) {
      selectedHabitIds.remove(id);
    } else {
      selectedHabitIds.add(id);
    }
    update(); // Notify GetBuilder
  }

  void clearSelection() {
    selectedHabitIds.clear();
    update(); // Notify GetBuilder
  }

  void deleteSelectedHabits() {
    if (selectedHabitIds.isEmpty) return;

    // Filter out habits to keep
    final List<HabitModel> habitsToKeep =
        db.todaysHabitList.where((h) => !selectedHabitIds.contains(h.id)).toList();

    // Identify IDs to delete from cloud
    final List<String> idsToDelete = List.from(selectedHabitIds);

    db.todaysHabitList = habitsToKeep;
    db.updateData();
    clearSelection();
    update();

    // Cloud deletion
    if (db.isUserLoggedIn()) {
      for (var id in idsToDelete) {
        db.deleteHabitFromCloud(id);
      }
    }
  }

  void updateSelectedHabitsColor(Color color) {
    if (selectedHabitIds.isEmpty) return;

    for (var habit in db.todaysHabitList) {
      if (selectedHabitIds.contains(habit.id)) {
        habit.colorValue = color.toARGB32();
      }
    }
    db.updateData();
    clearSelection();
    update();
  }

  void dbEditHabitByIndex(int index, String newName) {
    db.dbEditHabitByIndex(index, newName);
    update();
  }

  void dbAddHabit(String name) {
    db.dbAddHabit(name);
    update();
  }

  void reorderHabits(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final habit = db.todaysHabitList.removeAt(oldIndex);
    db.todaysHabitList.insert(newIndex, habit);
    db.updateData();
    update();
  }
}
