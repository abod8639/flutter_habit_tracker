import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.Getx.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/widget/myalartD.dart';

void addHabit(BuildContext context) {
  final c = Get.find<HabitController>();
  c.habitTextController.clear();
  showDialog(
    context: context,
    builder: (context) {
      return Myalartd(
        hintText: S.of(context).Addnewhabit,
        controller: c.habitTextController,
        onSave: () {
          final String habitName = c.habitTextController.text.trim();
          if (habitName.isNotEmpty) {
            c.db.addHabit(habitName);
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
            c.update();
          }
        },
      );
    },
  );
}
