import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/controller/sync_controller.dart';

Future<void> performSync(
  SyncController syncController,
  HabitController habitController,
) async {
  final habits = habitController.db.todaysHabitList;
  final result = await syncController.manualSync(habits);
  if (result != null) {
    habitController.updateHabits(result);
  }
}
