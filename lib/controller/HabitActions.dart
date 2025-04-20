// habit_actions.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/data/habit_db.dart';
import 'package:habit_tracker/view/widget/myalartD.dart';

void showAddHabitDialog(
  BuildContext context,
  TextEditingController controller,
  Habitdb db,
  VoidCallback update,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Myalartd(
        hintText: 'Add new Habit...',
        controller: controller,
        onSave: () {
          final String habitName = controller.text.trim();
          if (habitName.isNotEmpty) {
            db.todaysHabitList.add([habitName, false]);
            db.updateData();
            Navigator.of(context).pop();
            update();
          } else {
            Get.snackbar(
              'Error',
              'Habit name cannot be empty',
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

void showEditHabitDialog(
  int index,
  BuildContext context,
  TextEditingController controller,
  Habitdb db,
  VoidCallback update,
) {
  if (index >= 0 && index < db.todaysHabitList.length) {
    controller.text = db.todaysHabitList[index][0];
    showDialog(
      context: context,
      builder: (context) {
        return Myalartd(
          hintText: 'Edit This Habit',
          controller: controller,
          onSave: () {
            final String habitName = controller.text.trim();
            if (habitName.isNotEmpty) {
              db.todaysHabitList[index][0] = habitName;
              db.updateData();
              Navigator.of(context).pop();
              update();
            } else {
              Get.snackbar(
                'Error :',
                'The field can’t be empty :)',
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
}

void resetAllHabits(Habitdb db) {
  for (var habit in db.todaysHabitList) {
    habit[1] = false;
  }
  db.updateData();
  Get.snackbar(
    'Habits Reset',
    'All habits have been reset for the new day',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.green.withOpacity(0.7),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
  );
}

void showDeleteHabitDialog(
  int index,
  BuildContext context,
  Habitdb db,
  VoidCallback update,
) {
  if (index >= 0 && index < db.todaysHabitList.length) {
    Get.defaultDialog(
      buttonColor: Theme.of(context).colorScheme.secondary,
      cancelTextColor: Theme.of(context).colorScheme.primary,
      confirmTextColor: Theme.of(context).colorScheme.error,
      title: 'Delete Habit',
      middleText: 'Are you sure you want to delete this habit?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      onCancel: () => Get.back(),
      onConfirm: () {
        db.todaysHabitList.removeAt(index);
        db.updateData();
        update();
        Get.back();
      },
    );
  }
}

void toggleHabitStatus(
  bool? value,
  int index,
  Habitdb db,
  VoidCallback update,
) {
  if (index >= 0 && index < db.todaysHabitList.length) {
    db.todaysHabitList[index][1] = value ?? false;
    db.updateData();
    update();
  }
}

void showManualResetDialog(Habitdb db, VoidCallback update) {
  Get.defaultDialog(
    title: 'Reset All Habits',
    middleText:
        'Are you sure you want to reset all habits? All habits will be marked as incomplete.',
    textConfirm: 'Reset',
    textCancel: 'Cancel',
    confirmTextColor: Colors.white,
    onConfirm: () {
      for (var habit in db.todaysHabitList) {
        habit[1] = false;
      }
      db.updateData();
      update();
      Get.back();
    },
  );
}
