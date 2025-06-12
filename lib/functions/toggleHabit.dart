import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';

void toggleHabit(bool? value, int index) {
  HabitController controller = Get.put(HabitController());

  if (controller.db.getHabitByIndex(index) == null) return;
  controller.db.toggleHabitByIndex(index, value ?? false);
  controller.update();
}
