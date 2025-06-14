import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitController.dart';
import 'package:habit_tracker/generated/l10n.dart';

void deleteHabit(int index, BuildContext context) {
  HabitController c = Get.put(HabitController());

  if (c.db.getHabitByIndex(index) == null) return;

  Get.defaultDialog(
    buttonColor: Theme.of(context).colorScheme.secondary,
    cancelTextColor: Theme.of(context).colorScheme.primary,
    confirmTextColor: Theme.of(context).colorScheme.error,
    title: S.of(context).DeleteHabit,
    middleText: S.of(context).areyousureyouwanttothishabit,
    textConfirm: S.of(context).DeleteHabit,
    textCancel: S.of(context).Cancel,
    onCancel: () => Get.back(),
    onConfirm: () {
      c.db.deleteHabitByIndex(index);
      c.update();
      Get.back();
    },
  );
}
