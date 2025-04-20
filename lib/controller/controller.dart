// habit_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/HabitActions.dart';
import 'package:habit_tracker/data/habit_db.dart';
import 'package:habit_tracker/models/HabitUtils.dart';
import 'package:habit_tracker/services/HamitStorage.dart';
import 'package:hive/hive.dart';

class HabitController extends GetxController {
  final Habitdb db = Habitdb();
  final TextEditingController habitTextController = TextEditingController();
  late final Box _myBox;
  Timer? _resetCheckTimer;
  RxInt dayCount = 1.obs;
  Rx<DateTime?> lastResetDate = Rx<DateTime?>(null);
  RxInt index = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    _myBox = Hive.box(HabitStorage.boxName);
    initializeBox(_myBox, db);

    // Load data with reactive variables
    dayCount.value = _myBox.get(HabitStorage.dayCountKey) ?? 1;
    lastResetDate.value = getLastResetDate(_myBox);

    // Check for reset immediately
    checkAndResetHabits();

    // Set periodic check (using a more reasonable interval - 15 minutes)
    _resetCheckTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => checkAndResetHabits(),
    );
  }

  void checkAndResetHabits() {
    if (shouldResetHabits(lastResetDate.value)) {
      incrementDayCount();
      resetAllHabits(db);
      lastResetDate.value = DateTime.now();
      saveLastResetDate(_myBox, lastResetDate.value!);
    }
  }

  void incrementDayCount() {
    dayCount.value++;
    _myBox.put(HabitStorage.dayCountKey, dayCount.value);
  }

  void addHabit(BuildContext context) {
    habitTextController.clear();
    showAddHabitDialog(context, habitTextController, db, update);
  }

  void editHabit(int index, BuildContext context) {
    if (index < 0 || index >= db.todaysHabitList.length) return;
    showEditHabitDialog(index, context, habitTextController, db, update);
    db.updateData();
    update();
  }

  void deleteHabit(int index, BuildContext context) {
    if (index < 0 || index >= db.todaysHabitList.length) return;
    showDeleteHabitDialog(index, context, db, update);
  }

  void toggleHabit(bool? value, int index) {
    if (index < 0 || index >= db.todaysHabitList.length) return;
    toggleHabitStatus(value, index, db, update);
    db.updateData();
    update();
  }

  void manualReset() {
    showManualResetDialog(db, update);
  }

  @override
  void onClose() {
    _resetCheckTimer?.cancel();
    habitTextController.dispose();
    super.onClose();
  }

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000.0;
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600.0 &&
      MediaQuery.of(context).size.width < 1000.0;
  bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600.0;

  String getStartDay() {
    return _myBox.get(HabitStorage.startDayKey, defaultValue: "");
  }
}
