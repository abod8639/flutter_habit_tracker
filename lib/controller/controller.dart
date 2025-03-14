import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/custom/myalartD.dart';
import 'package:habit_tracker/data/habit_db.dart';
import 'package:hive/hive.dart';

class HabitController extends GetxController {
  // Constants
  static const String _boxName = "Habit_db";
  static const String _todoListKey = "TODOLIST";
  static const String _lastResetDateKey = "LAST_RESET_DATE";
  static const String _dayCountKey = "DAY_COUNT"; //
  static const String _startDayKey = "START_DAY"; //

  // Variables
  int? index;
  int dayCount = 1;
  final TextEditingController habitTextController = TextEditingController();
  final Habitdb db = Habitdb();
  late final Box _myBox;
  DateTime? lastResetDate;
  Timer? _resetCheckTimer;

  // Responsive design helpers
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000.0;
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600.0 &&
      MediaQuery.of(context).size.width < 1000.0;
  bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600.0;

  @override
  void onInit() {
    super.onInit();
    initializeBox();
  }

  Future<void> initializeBox() async {
    _myBox = Hive.box(_boxName);

    // Initialize data
    if (_myBox.get(_todoListKey) == null) {
      db.createDefaultData();
      // تهيئة عداد الأيام بالقيمة الابتدائية
      _myBox.put(_dayCountKey, 1);
      dayCount = 1;
    } else {
      db.loadData();
      // استرجاع قيمة عداد الأيام من التخزين
      dayCount = _myBox.get(_dayCountKey) ?? 1;
    }

    // Load last reset date and check for day change
    lastResetDate = _getLastResetDate();
    checkAndResetHabits();

    // Set timer to check for day change every hour
    _resetCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => checkAndResetHabits(),
    );

    update();
  }

  void get() {
    _myBox.get(_startDayKey);
    update();
  }

  void checkAndResetHabits() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    if (lastResetDate == null || !_isSameDay(today, lastResetDate!)) {
      // زيادة عداد الأيام قبل إعادة ضبط العادات
      incrementDayCount();
      resetAllHabits();
      lastResetDate = today;
      _saveLastResetDate(today);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // دالة جديدة لزيادة عداد الأيام وحفظه في Hive
  void incrementDayCount() {
    dayCount++;
    _myBox.put(_dayCountKey, dayCount);
    update();
  }

  void resetAllHabits() {
    for (var habit in db.todaysHabitList) {
      habit[1] = false;
    }

    db.updateData();

    _showResetNotification();
  }

  void _showResetNotification() {
    Get.snackbar(
      'تم إعادة ضبط العادات',
      'تم إعادة ضبط جميع العادات ليوم جديد - اليوم $dayCount',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
    );
  }

  void _saveLastResetDate(DateTime date) {
    _myBox.put(_lastResetDateKey, date.toIso8601String());
  }

  DateTime? _getLastResetDate() {
    final String? dateStr = _myBox.get(_lastResetDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  void toggleHabit(bool? value, int index) {
    if (index >= 0 && index < db.todaysHabitList.length) {
      db.todaysHabitList[index][1] = value ?? false;
      db.updateData();
      update();
    }
  }

  void addHabit(BuildContext context) {
    habitTextController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return Myalartd(
          hintText: 'Add newHabit...',
          controller: habitTextController,
          onSave: () {
            final String habitName = habitTextController.text.trim();
            if (habitName.isNotEmpty) {
              db.todaysHabitList.add([habitName, false]);
              db.updateData();
              Navigator.of(context).pop();
              update();
            } else {
              // Show error for empty habit name
              Get.snackbar(
                'خطأ',
                'لا يمكن ترك اسم العادة فارغاً',
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

  void deleteHabit(int index, context) {
    if (index >= 0 && index < db.todaysHabitList.length) {
      // Show confirmation dialog

      Get.defaultDialog(
        title: 'Delete Habit', //delete
        middleText:
            'ar you sure you want to delete this habit ?', //ar you sure you want to delete this habit
        textConfirm: 'Delete',
        cancelTextColor: Theme.of(context).primaryColor,
        buttonColor: Theme.of(context).colorScheme.primary,
        confirmTextColor: Theme.of(context).colorScheme.onPrimary,
        textCancel: 'Cancel',
        onCancel: () => Get.back(),
        onConfirm: () {
          Get.back();
          db.todaysHabitList.removeAt(index);
          db.updateData();
          update();
        },
      );
    }
  }

  void editHabit(int index, BuildContext context) {
    if (index >= 0 && index < db.todaysHabitList.length) {
      habitTextController.text = db.todaysHabitList[index][0];
      showDialog(
        context: context,
        builder: (context) {
          return Myalartd(
            hintText: 'Edit This Habit',
            controller: habitTextController,
            onSave: () {
              final String habitName = habitTextController.text.trim();
              if (habitName.isNotEmpty) {
                db.todaysHabitList[index][0] = habitName;
                db.updateData();
                Navigator.of(context).pop();
                update();
              } else {
                Get.snackbar(
                  'Error :',
                  'The field can`t be empty :)',
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

  void manualReset() {
    Get.defaultDialog(
      title: 'إعادة ضبط جميع العادات',
      middleText:
          'هل أنت متأكد من رغبتك في إعادة ضبط جميع العادات؟ سيتم تعليم جميع العادات كغير مكتملة.',
      textConfirm: 'إعادة ضبط',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      onConfirm: () {
        // لا نزيد dayCount في إعادة الضبط اليدوية
        resetAllHabits();
        update();
        Get.back();
      },
    );
  }

  @override
  void onClose() {
    _resetCheckTimer?.cancel();
    habitTextController.dispose();
    super.onClose();
  }
}
