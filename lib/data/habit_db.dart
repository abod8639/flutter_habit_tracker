// 2. Updated Habitdb class with Supabase integration
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habit_tracker/data/HabitStorage.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/models/date_time.dart';
import 'package:habit_tracker/services/syncHiveToSupabase.dart';
import 'package:hive/hive.dart';

class Habitdb {
  final myBox = Hive.box(HabitStorage.boxName);

  // User ID for Supabase (you should implement proper user authentication)
  String get userId => myBox.get('user_id', defaultValue: 'default_user');

  List<HabitModel> _habits = [];
  Map<DateTime, int> heatmapDateSet = {};

  int _completedCount = 1;
  bool _dataChanged = false;
  final bool _isOnline = false;

  // Check if device is online
  Future<void> _checkConnectivity() async {
    // _isOnline = await SupabaseService.hasInternetConnection();
  }

  // Sync data with Supabase
  Future<void> syncWithSupabase() async {
    try {
      await _checkConnectivity();

      if (!_isOnline) {
        debugPrint('⚠️ Device is offline, skipping sync');
        return;
      }

      debugPrint('🔄 Starting sync with Supabase...');

      // Upload current habits to Supabase
      final uploadSuccess = await SupabaseService.uploadHabits(_habits, userId);

      if (uploadSuccess) {
        // Upload heatmap data
        await SupabaseService.uploadHeatmapData(heatmapDateSet, userId);

        // Mark last sync time
        myBox.put('last_sync', DateTime.now().toIso8601String());

        debugPrint('✅ Sync completed successfully');
      }
    } catch (e) {
      debugPrint('❌ Error during sync: $e');
    }
  }

  // Download data from Supabase (for app restoration or multi-device sync)
  Future<void> downloadFromSupabase() async {
    try {
      await _checkConnectivity();

      if (!_isOnline) {
        debugPrint('⚠️ Device is offline, cannot download');
        return;
      }

      debugPrint('📥 Downloading data from Supabase...');

      // Download habits
      final cloudHabits = await SupabaseService.downloadHabits(userId);

      // Download heatmap
      final cloudHeatmap = await SupabaseService.downloadHeatmapData(userId);

      if (cloudHabits.isNotEmpty) {
        _habits = cloudHabits;
        _updateCache();

        // Save to local storage
        updateData();
      }

      if (cloudHeatmap.isNotEmpty) {
        heatmapDateSet = cloudHeatmap;
      }

      debugPrint('✅ Download completed successfully');
    } catch (e) {
      debugPrint('❌ Error during download: $e');
    }
  }

  // Auto-sync when data changes
  Future<void> _autoSync() async {
    try {
      // Only sync if online and data has changed
      if (_dataChanged && _isOnline) {
        await syncWithSupabase();
      }
    } catch (e) {
      debugPrint('⚠️ Auto-sync failed: $e');
    }
  }

  // Modified updateData to include sync
  void updateData() async {
    try {
      // Save to local storage first (original functionality)
      myBox.put(HabitStorage.habitListKey, todaysHabitList);

      final String today = todaysDateFormatted();
      myBox.put(today, todaysHabitList);

      for (var habit in _habits) {
        final String historyKey = "${habit.name}_$today";
        myBox.put(historyKey, habit.isCompleted);
      }

      habitCalculate();
      loadHeatmap();

      _dataChanged = false;

      // Auto-sync with Supabase
      await _autoSync();
    } catch (e) {
      debugPrint('❌ Error updating habit data: $e');
    }
  }

  // Rest of the original methods remain the same...
  List get todaysHabitList {
    return _habits.map((habit) => habit.toLocalFormat()).toList();
  }

  set todaysHabitList(List value) {
    _habits = value.map((item) => HabitModel.fromLocalFormat(item)).toList();
    _updateCache();
  }

  void createDefaultData() {
    try {
      debugPrint('🆕 Creating default habit data');
      _habits = HabitStorage.defaultHabits;

      myBox.put(HabitStorage.startDayKey, todaysDateFormatted());
      updateData();

      debugPrint('✅ Default data created successfully');
    } catch (e) {
      debugPrint('❌ Error creating default data: $e');
      _createMinimalDefaultData();
    }
  }

  void _createMinimalDefaultData() {
    _habits = [
      HabitModel(
        id: '1',
        name: "Read a Book",
        isCompleted: true,
        createdAt: DateTime.now(),
      ),
    ];
    myBox.put(HabitStorage.startDayKey, todaysDateFormatted());
    updateData();
  }

  void loadData() {
    try {
      debugPrint('📥 Loading habit data');
      if (myBox.get(HabitStorage.habitListKey) != null) {
        List data = myBox.get(HabitStorage.habitListKey);
        _habits = data.map((item) => HabitModel.fromLocalFormat(item)).toList();
        debugPrint('📋 Loaded ${_habits.length} habits');
      } else {
        debugPrint('⚠️ No habit data found, using empty list');
        _habits = [];
      }

      _updateCache();
      loadHeatmap();
    } catch (e) {
      debugPrint('❌ Error loading habit data: $e');
      _habits = [];
      heatmapDateSet = {};
    }
  }

  void _updateCache() {
    _completedCount = _habits.where((habit) => habit.isCompleted).length;
    _dataChanged = true;
  }

  void habitCalculate() {
    try {
      if (!_dataChanged) {
        debugPrint('📊 Using cached completion count');
      } else {
        _completedCount = _habits.where((habit) => habit.isCompleted).length;
      }

      double completionRate =
          _habits.isEmpty ? 0.0 : _completedCount / _habits.length;
      String rateString = completionRate.toStringAsFixed(1);

      final dateKey =
          "${HabitStorage.habitStrengthPrefix}${todaysDateFormatted()}";
      myBox.put(dateKey, rateString);

      debugPrint('📊 Habit completion rate: $rateString');
    } catch (e) {
      debugPrint('❌ Error calculating habit completion: $e');
    }
  }

  List<Map<String, dynamic>> getIncompleteHabits() {
    return _habits
        .where((habit) => !habit.isCompleted)
        .map(
          (habit) => {
            "id": habit.id,
            "name": habit.name,
            "completed": habit.isCompleted,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> getCompletedHabits() {
    return _habits
        .where((habit) => habit.isCompleted)
        .map(
          (habit) => {
            "id": habit.id,
            "name": habit.name,
            "completed": habit.isCompleted,
          },
        )
        .toList();
  }

  void loadHeatmap() {
    try {
      String? startDateStr = myBox.get(HabitStorage.startDayKey);

      DateTime startDate;
      try {
        startDate = createDateTimeObject(startDateStr ?? todaysDateFormatted());
      } catch (e) {
        debugPrint('⚠️ Error parsing start date: $e');
        startDateStr = todaysDateFormatted();
        myBox.put(HabitStorage.startDayKey, startDateStr);
        startDate = DateTime.now();
      }

      int daysInBetween = DateTime.now().difference(startDate).inDays;

      if (daysInBetween < 0 || daysInBetween > 366) {
        debugPrint(
          '⚠️ Invalid days between: $daysInBetween, resetting to today',
        );
        startDateStr = todaysDateFormatted();
        myBox.put(HabitStorage.startDayKey, startDateStr);
        startDate = DateTime.now();
        daysInBetween = 0;
      }

      heatmapDateSet = {};

      String lastSavedDate = myBox.get(
        HabitStorage.lastSavedDateKey,
        defaultValue: "",
      );
      String todayDate = todaysDateFormatted();

      if (lastSavedDate != todayDate) {
        debugPrint('📅 New day detected, resetting habits');
        for (var habit in _habits) {
          habit.isCompleted = false;
        }
        _updateCache();
        myBox.put(HabitStorage.lastSavedDateKey, todayDate);
      }

      for (int i = 0; i < daysInBetween + 1; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String yyyymmdd = convertDateTimeToString(currentDate);

        String? habitStrength = myBox.get(
          "${HabitStorage.habitStrengthPrefix}$yyyymmdd",
        );
        double strength = 0.0;

        try {
          strength = double.parse(habitStrength ?? '0.0');
        } catch (e) {
          debugPrint('⚠️ Error parsing strength for date $yyyymmdd: $e');
          strength = 0.0;
        }

        final percentForDate = <DateTime, int>{
          DateTime(currentDate.year, currentDate.month, currentDate.day):
              (strength * 10).toInt(),
        };

        heatmapDateSet.addEntries(percentForDate.entries);
      }

      debugPrint('📊 Heatmap loaded with ${heatmapDateSet.length} days');
    } catch (e) {
      debugPrint('❌ Error loading heatmap: $e');
      heatmapDateSet = {};
    }
  }

  HabitModel? getHabitByIndex(int index) {
    if (index >= 0 && index < _habits.length) {
      return _habits[index];
    }
    return null;
  }

  void addHabit(String name) {
    _habits.add(
      HabitModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    );
    _dataChanged = true;
    updateData();
  }

  void editHabitByIndex(int index, String newName) {
    if (index >= 0 && index < _habits.length) {
      _habits[index].name = newName;
      _dataChanged = true;
      updateData();
    }
  }

  void deleteHabitByIndex(int index) {
    if (index >= 0 && index < _habits.length) {
      _habits.removeAt(index);
      _dataChanged = true;
      updateData();
    }
  }

  void toggleHabitByIndex(int index, bool value) {
    if (index >= 0 && index < _habits.length) {
      final habit = _habits[index];
      habit.isCompleted = value;
      habit.completedAt = value ? DateTime.now() : null;

      final now = DateTime.now();
      final todayStr = convertDateTimeToString(now);
      final historyKey = "${habit.name}_$todayStr";
      myBox.put(historyKey, value);

      _dataChanged = true;
      updateData();
    }
  }

  // Additional utility methods for Supabase integration

  // Force sync with Supabase
  Future<void> forceSyncWithSupabase() async {
    _dataChanged = true;
    await syncWithSupabase();
  }

  // Get last sync time
  DateTime? getLastSyncTime() {
    final lastSyncStr = myBox.get('last_sync');
    if (lastSyncStr != null) {
      return DateTime.parse(lastSyncStr);
    }
    return null;
  }
}
