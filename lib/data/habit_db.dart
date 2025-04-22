import 'package:flutter/foundation.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/models/date_time.dart';
import 'package:habit_tracker/services/HamitStorage.dart';
import 'package:hive/hive.dart';

/// Database box reference
final myBox = Hive.box(HabitStorage.boxName);

/// Main database class for managing habits
class Habitdb {
  /// Internal list of habit objects
  List<HabitModel> _habits = [];

  /// Heatmap data for calendar visualization
  Map<DateTime, int> heatmapDateSet = {};

  /// Cache to reduce redundant calculations
  int _completedCount = 0;
  bool _dataChanged = false;

  /// For backward compatibility - convert HabitModel list to the old format
  List get todaysHabitList {
    return _habits.map((habit) => habit.toLocalFormat()).toList();
  }

  /// Add a setter to update the internal habits list from the old format
  set todaysHabitList(List value) {
    _habits = value.map((item) => HabitModel.fromLocalFormat(item)).toList();
    _updateCache();
  }

  /// Create default data for first-time users
  void createDefaultData() {
    try {
      debugPrint('🆕 Creating default habit data');
      _habits =
          HabitStorage.defaultHabits
              .map(
                (habit) => HabitModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: habit["name"],
                  isCompleted: habit["isCompleted"],
                  createdAt: DateTime.now(),
                ),
              )
              .toList();

      // Save the start day
      myBox.put(HabitStorage.startDayKey, todaysDateFormatted());

      // Save the initial data
      updateData();

      debugPrint('✅ Default data created successfully');
    } catch (e) {
      debugPrint('❌ Error creating default data: $e');
      // Fallback to basic data
      _createMinimalDefaultData();
    }
  }

  /// Minimal default data creation as fallback
  void _createMinimalDefaultData() {
    _habits = [
      HabitModel(
        id: '1',
        name: "Read a Book",
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    ];
    myBox.put(HabitStorage.startDayKey, todaysDateFormatted());
    updateData();
  }

  /// Load existing data from storage
  void loadData() {
    try {
      debugPrint('📥 Loading habit data');
      if (myBox.get(HabitStorage.todoListKey) != null) {
        // Convert from old format
        List data = myBox.get(HabitStorage.todoListKey);
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
      // Recover with empty data
      _habits = [];
      heatmapDateSet = {};
    }
  }

  /// Update cache values for quick access
  void _updateCache() {
    _completedCount = _habits.where((habit) => habit.isCompleted).length;
    _dataChanged = true;
  }

  /// Save data to persistent storage
  void updateData() {
    try {
      // Save in the old format for backward compatibility
      myBox.put(HabitStorage.todoListKey, todaysHabitList);

      // Also save today's data with date
      myBox.put(todaysDateFormatted(), todaysHabitList);

      habitCalculate();
      loadHeatmap();

      _dataChanged = false;
    } catch (e) {
      debugPrint('❌ Error updating habit data: $e');
    }
  }

  /// Calculate habit completion rate for the day
  void habitCalculate() {
    try {
      // Use cached count when possible
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

  /// Get list of incomplete habits
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

  /// Get list of completed habits
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

  /// Load heatmap data for visualization
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

      // Ensure we have a reasonable number of days (protect against bad data)
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
        // Reset all habits to false for the new day
        for (var habit in _habits) {
          habit.isCompleted = false;
        }
        _updateCache();
        myBox.put(HabitStorage.lastSavedDateKey, todayDate);
      }

      // Build the heatmap
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

  /// Get a single habit by index
  HabitModel? getHabitByIndex(int index) {
    if (index >= 0 && index < _habits.length) {
      return _habits[index];
    }
    return null;
  }

  /// Add a new habit
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

  /// Edit a habit by index
  void editHabitByIndex(int index, String newName) {
    if (index >= 0 && index < _habits.length) {
      _habits[index].name = newName;
      _dataChanged = true;
      updateData();
    }
  }

  /// Delete a habit by index
  void deleteHabitByIndex(int index) {
    if (index >= 0 && index < _habits.length) {
      _habits.removeAt(index);
      _dataChanged = true;
      _updateCache();
      updateData();
    }
  }

  /// Toggle a habit completion status by index
  void toggleHabitByIndex(int index, bool value) {
    if (index >= 0 && index < _habits.length) {
      _habits[index].isCompleted = value;
      if (value) {
        _habits[index].completedAt = DateTime.now();
      } else {
        _habits[index].completedAt = null;
      }
      _dataChanged = true;
      _updateCache();
      updateData();
    }
  }
}
