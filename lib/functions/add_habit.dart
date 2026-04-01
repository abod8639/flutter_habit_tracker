import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/components/myalart_dialog.dart';

void addHabit(BuildContext context) {
  final c = Get.find<HabitController>();
  c.habitTextController.clear();
  showDialog(
    context: context,
    builder: (context) {
      return MyalartDialog(
        hintText: S.current.addNewHabit,
        controller: c.habitTextController,
        onSave: () {
          final String habitName = c.habitTextController.text.trim();
          if (habitName.isNotEmpty) {
            c.db.dbAddHabit(habitName);
            c.update();
            Navigator.of(context).pop();
          } else {
            Get.snackbar(
              S.current.error,
              S.current.theFieldCantBeEmpty,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withValues(alpha: 0.7),
              colorText: Colors.white,
            );
            c.update();
          }
        },
      );
    },
  );
}
