import 'package:habit_tracker/models/date_time.dart';
import 'package:hive/hive.dart';

final myBox = Hive.box("Habit_db");

class Habitdb {
  List todaysHabitList = [];
  Map<DateTime, int> heatmapDateSet = {};

  void createDefaultData() {
    todaysHabitList = [
      ["Read a Book", false],
      ["Learn Something New", false],
      ["Relaxation", false],
    ];
    myBox.put("START_DAY", todaysDateFormatted());
  }

  void loadData() {
    if (myBox.get("TODOLIST") != null) {
      todaysHabitList = myBox.get("TODOLIST");
    }
    loadHeatmap();
  }

  void updateData() {
    myBox.put("TODOLIST", todaysHabitList);

    myBox.put(todaysDateFormatted(), todaysHabitList);

    habitCalculate();
    loadHeatmap();
  }

  void habitCalculate() {
    int count = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        count++;
      }
    }

    String date =
        todaysHabitList.isEmpty
            ? "0.0"
            : (count / todaysHabitList.length).toStringAsFixed(1);

    myBox.put("TODAY_HABIT${todaysDateFormatted()}", date);
  }

  List<Map<String, dynamic>> getIncompleteHabits() {
    return todaysHabitList
        .where((habit) => habit[1] == false) // فلترة العادات غير المكتملة
        .map((habit) => {"name": habit[0], "completed": habit[1]})
        .toList();
  }

  List<Map<String, dynamic>> getCompletedHabits() {
    return todaysHabitList
        .where((habit) => habit[1] == true) // فلترة العادات غير المكتملة
        .map((habit) => {"name": habit[0], "completed": habit[1]})
        .toList();
  }

  void loadHeatmap() {
    try {
      String? startDateStr = myBox.get("START_DAY");

      DateTime startDate;
      try {
        startDate = createDateTimeObject(startDateStr ?? todaysDateFormatted());
      } catch (e) {
        startDateStr = todaysDateFormatted();
        myBox.put("START_DAY", startDateStr);
        startDate = DateTime.now();
      }

      int daysInBetween = DateTime.now().difference(startDate).inDays;

      heatmapDateSet = {};

      String lastSavedDate = myBox.get("LAST_SAVED_DATE", defaultValue: "");
      String todayDate = todaysDateFormatted();

      if (lastSavedDate != todayDate) {
        for (int i = 0; i < todaysHabitList.length; i++) {
          todaysHabitList[i][1] = false;
        }
        myBox.put("LAST_SAVED_DATE", todayDate);
      }

      for (int i = 0; i < daysInBetween + 1; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String yyyymmdd = convertDateTimeToString(currentDate);

        String? habitStrength = myBox.get("TODAY_HABIT$yyyymmdd");
        double strength = 0.0;

        try {
          strength = double.parse(habitStrength ?? '0.0');
        } catch (e) {
          strength = 0.0;
        }

        final percentForDate = <DateTime, int>{
          DateTime(currentDate.year, currentDate.month, currentDate.day):
              (strength * 10).toInt(),
        };

        heatmapDateSet.addEntries(percentForDate.entries);
      }
    } catch (e) {
      print("Error in loadHeatmap: $e");
      heatmapDateSet = {};
    }
  }
}
