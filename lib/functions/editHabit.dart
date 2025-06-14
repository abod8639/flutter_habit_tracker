import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/view/widget/myalartD.dart';

void editHabit(int index, BuildContext context) {
  HabitController c = Get.put(HabitController());
  HabitModel? habit = c.db.getHabitByIndex(index);
  if (habit == null) return;

  c.habitTextController.text = habit.name;
  showDialog(
    context: context,
    builder: (context) {
      return Myalartd(
        hintText: S.of(context).EditThisHabit,
        controller: c.habitTextController,
        onSave: () {
          final String habitName = c.habitTextController.text.trim();
          if (habitName.isNotEmpty) {
            c.db.editHabitByIndex(index, habitName);
            c.update();
            Navigator.of(context).pop();
          } else {
            Get.snackbar(
              S.of(context).Error,
              S.of(context).Thefieldcanybeempty,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.7),
              colorText: Colors.white,
            );
          }
        },
      );
    },
  );
}
