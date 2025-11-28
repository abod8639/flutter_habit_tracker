import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

void deleteHabit(int index, BuildContext context) {
  HabitController c = Get.find<HabitController>();

  if (c.db.getHabitByIndex(index) == null) return;

  Get.defaultDialog(
    buttonColor: Theme.of(context).colorScheme.secondary,
    cancelTextColor: Theme.of(context).colorScheme.primary,
    confirmTextColor: Theme.of(context).colorScheme.error,
    title: S.current.deleteHabit,
    middleText: S.current.areYouSureYouWantToDeleteThisHabit,
    textConfirm: S.current.deleteHabit,
    textCancel: S.current.cancel,
    onCancel: () => Get.back(),
    onConfirm: () {
      c.db.dbDeleteHabitByIndex(index);
      c.update();
      Get.back();
    },
  );
}
