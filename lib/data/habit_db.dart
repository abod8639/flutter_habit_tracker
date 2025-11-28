import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/data/HabitLocalDataSource.dart';
import 'package:habit_tracker/data/HabitStorage.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/models/date_time.dart';
import 'package:habit_tracker/services/firestore_service.dart';
import 'package:hive/hive.dart';



class Habitdb {
  late final HabitLocalDataSource _localDataSource;
  late final FirestoreService _firestoreService;

  List<HabitModel> _habits = [];
  Map<DateTime, int> heatmapDateSet = {};

  int _completedCount = 0;
  bool _dataChanged = false;

  Habitdb() {
    final myBox = Hive.box(HabitStorage.boxName);
    _localDataSource = HabitLocalDataSource(myBox);
    _firestoreService = FirestoreService();
  }

  DateTime? getLastSyncTime() {
    return _localDataSource.getLastSyncTime();
  }

  // --- Data Management ---

  void updateData() async {
    try {
      _localDataSource.saveHabits(_habits);
      habitCalculate();
      loadHeatmap();
      _dataChanged = false;
      
      // Upload to cloud in background
      if (_firestoreService.isUserLoggedIn) {
        _firestoreService.uploadHabits(_habits).catchError((e) {
          debugPrint('⚠️ Background upload failed: $e');
        });
      }
    } catch (e) {
      debugPrint('❌ Error updating habit data: $e');
    }
  }

  List<HabitModel> get todaysHabitList {
    return _habits;
  }

  set todaysHabitList(List<HabitModel> value) {
    _habits = value;
    _updateCache();
  }

  void createDefaultData() {
    try {
      debugPrint('🆕 Creating default habit data');
      _habits = HabitStorage.defaultHabits;
      _localDataSource.setStartDate();
      updateData();
      debugPrint('✅ Default data created successfully');
    } catch (e) {
      debugPrint('❌ Error creating default data: $e');
    }
  }

  void loadData() {
    try {
      debugPrint('📥 Loading habit data');
      _habits = _localDataSource.loadHabits();
      if (_habits.isNotEmpty) {
        debugPrint('📋 Loaded ${_habits.length} habits');
      } else {
        debugPrint('⚠️ No habit data found, using empty list');
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

  // --- Business Logic ---

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

      _localDataSource.saveHabitStrength(todaysDateFormatted(), rateString);
      debugPrint('📊 Habit completion rate: $rateString');
      
      // Upload history to cloud
      if (_firestoreService.isUserLoggedIn) {
        _firestoreService.uploadHabitHistory(
          todaysDateFormatted(),
          rateString,
        ).catchError((e) {
          debugPrint('⚠️ History upload failed: $e');
        });
      }
    } catch (e) {
      debugPrint('❌ Error calculating habit completion: $e');
    }
  }

  List<Map<String, dynamic>> getIncompleteHabits() {
    return _habits
        .where((habit) => !habit.isCompleted)
        .map((habit) =>
            {"id": habit.id, "name": habit.name, "completed": habit.isCompleted})
        .toList();
  }

  List<Map<String, dynamic>> getCompletedHabits() {
    return _habits
        .where((habit) => habit.isCompleted)
        .map((habit) =>
            {"id": habit.id, "name": habit.name, "completed": habit.isCompleted})
        .toList();
  }

  void loadHeatmap() {
    try {
      String startDateStr = _localDataSource.getStartDate();
      DateTime startDate;
      try {
        startDate = createDateTimeObject(startDateStr);
      } catch (e) {
        debugPrint('⚠️ Error parsing start date: $e');
        startDateStr = todaysDateFormatted();
        _localDataSource.updateStartDate(startDateStr);
        startDate = DateTime.now();
      }

      int daysInBetween = DateTime.now().difference(startDate).inDays;

      heatmapDateSet = {};

      String lastSavedDate = _localDataSource.getLastSavedDate();
      String todayDate = todaysDateFormatted();

      if (lastSavedDate != todayDate) {
        debugPrint('📅 New day detected, resetting habits');
        for (var habit in _habits) {
          habit.isCompleted = false;
        }
        _updateCache();
        _localDataSource.setLastSavedDate(todayDate);
      }

      for (int i = 0; i < daysInBetween + 1; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String yyyymmdd = convertDateTimeToString(currentDate);

        String? habitStrength = _localDataSource.getHabitStrength(yyyymmdd);
        double strength = 0.0;
        try {
          strength = double.parse(habitStrength ?? "00000000");
        } catch (e) {
          debugPrint('⚠️ Error parsing strength for date $yyyymmdd: $e');
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

  // --- Habit CRUD ---

  HabitModel? getHabitByIndex(int index) {
    if (index >= 0 && index < _habits.length) {
      return _habits[index];
    }
    return null;
  }

  void dbAddHabit(String name) {
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

  void dbEditHabitByIndex(int index, String newName) {
    if (index >= 0 && index < _habits.length) {
      _habits[index].name = newName;
      _dataChanged = true;
      updateData();
    }
  }

  void dbDeleteHabitByIndex(int index) {
    if (index >= 0 && index < _habits.length) {
      final habitId = _habits[index].id;
      _habits.removeAt(index);
      _dataChanged = true;
      updateData();
      
      // Delete from cloud
      if (_firestoreService.isUserLoggedIn) {
        _firestoreService.deleteHabit(habitId).catchError((e) {
          debugPrint('⚠️ Cloud delete failed: $e');
        });
      }
    }
  }

  void dbToggleHabitByIndex(int index, bool value) {
    if (index >= 0 && index < _habits.length) {
      final habit = _habits[index];
      habit.isCompleted = value;
      habit.completedAt = value ? DateTime.now() : null;

      _localDataSource.saveHabitCompletionHistory(habit.name, value);

      _dataChanged = true;
      updateData();
    }
  }
}
