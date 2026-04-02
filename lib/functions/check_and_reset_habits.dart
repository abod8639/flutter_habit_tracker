import 'package:get/get.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/functions/habit_utils.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:hive/hive.dart';

/// Check if habits need to be reset for a new day
Future<void> checkAndResetHabits() async {
  if (!Get.isRegistered<HabitController>()) return;
  final HabitController c = Get.find<HabitController>();
  final box = Hive.box(HabitStorage.boxName);
  
  try {
    final lastResetDate = getLastResetDate(box);
    
    if (shouldResetHabits(lastResetDate)) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final normalizedDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      final yesterdayStr = convertDateTimeToString(normalizedDate);
      
      final currentHabits = List<HabitEntity>.from(c.habits);

      // Save each habit's current state to history
      for (var habit in currentHabits) {
        final String historyKey = "${habit.name}_$yesterdayStr";
        box.put(historyKey, habit.isCompleted);
      }

      // Perform reset: set all habits to not completed
      final resetHabits = currentHabits.map((h) => HabitModel.fromEntity(h.copyWith(
        isCompleted: false,
        completedAt: null,
        updatedAt: DateTime.now(),
      ))).toList();
      
      box.put(HabitStorage.habitListKey, resetHabits);
      
      // Update day count
      int dayCount = box.get(HabitStorage.dayCountKey) ?? 1;
      box.put(HabitStorage.dayCountKey, dayCount + 1);
      
      // Update last reset date
      final now = DateTime.now();
      saveLastResetDate(box, now);

      // Refresh controller state
      // We can't call private _loadHabits, but we can call public ones if available 
      // or just wait for the next timer tick or manual refresh.
      // For now, let's assume the controller will refresh itself or we can trigger it.
    }
  } catch (e) {
    // Error handling
  }
}
