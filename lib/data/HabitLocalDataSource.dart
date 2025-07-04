

import 'package:habit_tracker/data/HabitStorage.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/models/date_time.dart';
import 'package:hive/hive.dart';


// =================================================================
// DATA SOURCES
// =================================================================

class HabitLocalDataSource {
  final Box _myBox;

  HabitLocalDataSource(this._myBox);

  String get userId => _myBox.get('user_id', defaultValue: 'default_user');

  List<HabitModel> loadHabits() {
    if (_myBox.get(HabitStorage.habitListKey) != null) {
      List data = _myBox.get(HabitStorage.habitListKey);
      return data.map((item) => HabitModel.fromLocalFormat(item)).toList();
    }
    return [];
  }

  void saveHabits(List<HabitModel> habits) {
    final todaysHabitList =
        habits.map((habit) => habit.toLocalFormat()).toList();
    _myBox.put(HabitStorage.habitListKey, todaysHabitList);

    final String today = todaysDateFormatted();
    _myBox.put(today, todaysHabitList);

    for (var habit in habits) {
      final String historyKey = "${habit.name}_$today";
      _myBox.put(historyKey, habit.isCompleted);
    }
  }

  void saveHabitCompletionHistory(String habitName, bool isCompleted) {
    final String today = todaysDateFormatted();
    final String historyKey = "${habitName}_$today";
    _myBox.put(historyKey, isCompleted);
  }

  void setStartDate() {
    _myBox.put(HabitStorage.startDayKey, todaysDateFormatted());
  }

  String getStartDate() {
    return _myBox.get(HabitStorage.startDayKey,
        defaultValue: todaysDateFormatted());
  }

  void updateStartDate(String date) {
    _myBox.put(HabitStorage.startDayKey, date);
  }

  void saveHabitStrength(String date, String strength) {
    final dateKey = "${HabitStorage.habitStrengthPrefix}$date";
    _myBox.put(dateKey, strength);
  }

  String? getHabitStrength(String yyyymmdd) {
    return _myBox.get("${HabitStorage.habitStrengthPrefix}$yyyymmdd");
  }

  String getLastSavedDate() {
    return _myBox.get(HabitStorage.lastSavedDateKey, defaultValue: "");
  }

  void setLastSavedDate(String date) {
    _myBox.put(HabitStorage.lastSavedDateKey, date);
  }

  DateTime? getLastSyncTime() {
    final lastSyncStr = _myBox.get('last_sync');
    if (lastSyncStr != null) {
      return DateTime.parse(lastSyncStr);
    }
    return null;
  }

  Future<void> markLastSyncTime() async {
    _myBox.put('last_sync', DateTime.now().toIso8601String());
  }
}
