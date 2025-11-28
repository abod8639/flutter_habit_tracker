import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/widget/myalartD.dart';

void editHabit(int index, BuildContext context) {
  HabitController c = Get.find<HabitController>();

  showDialog(
    context: context,
    builder: (context) {
      return Myalartd(
        hintText: S.current.editThisHabit,
        controller: c.habitTextController,
        onSave: () {
          final String habitName = c.habitTextController.text.trim();
          if (habitName.isNotEmpty) {
            c.db.dbEditHabitByIndex(index, habitName);
            c.update();
            Navigator.of(context).pop();
          } else {
            Get.snackbar(
              S.current.error,
              S.current.theFieldCantBeEmpty,
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
