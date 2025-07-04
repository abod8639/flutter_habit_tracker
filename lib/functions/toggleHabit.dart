import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';

void toggleHabit(bool? value, int index) {
  HabitController controller = Get.put(HabitController());
  final habit = controller.db.getHabitByIndex(index);
  if (habit == null) return;

  // Toggle habit in database
  controller.db.toggleHabitByIndex(index, value ?? false);

  // Update history
  final now = DateTime.now();
  final normalizedDate = DateTime(now.year, now.month, now.day);
  final currentHistory = Map<String, Map<DateTime, bool>>.from(
    controller.habitHistoryMap.value,
  );

  if (!currentHistory.containsKey(habit.name)) {
    currentHistory[habit.name] = {};
  }
  currentHistory[habit.name]![normalizedDate] = value ?? false;
  controller.habitHistoryMap.value = currentHistory;

  controller.update();
}
