import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/utils/restart_widget.dart';
import 'package:habit_tracker/services/firestore_service.dart';
import 'package:hive/hive.dart';

/// Delete all data from the Habit database safely
Future<bool> clearAllHabitData() async {
  try {
    // debugPrint('Starting habit data clearing process...');

    // Get the box reference
    final Box box = Hive.box(HabitStorage.boxName);

    // Check if box is open
    if (!box.isOpen) {
      // debugPrint('Box is not open, attempting to open...');
      await Hive.openBox(HabitStorage.boxName);
    }

    // Clear all data step by step
    await _clearDataStepByStep(box);

    // debugPrint('All habit data cleared successfully');
    return true;
  } catch (e) {
    // debugPrint('Error clearing habit data: $e');
    // debugPrint('Stack trace: $stack');

    // Try alternative clearing method
    return await _alternativeClearMethod();
  }
}

/// Clear data step by step to avoid issues
Future<void> _clearDataStepByStep(Box box) async {
  try {
    // Clear main habit data
    await box.delete(HabitStorage.habitListKey);
    // debugPrint('Cleared habit list');

    // Clear date-related data
    await box.delete(HabitStorage.lastResetDateKey);
    await box.delete(HabitStorage.dayCountKey);
    await box.delete(HabitStorage.startDayKey);
    await box.delete(HabitStorage.lastSavedDateKey);
    // debugPrint('Cleared date data');

    // Clear habit strength data (keys that start with habit strength prefix)
    final List<dynamic> keysToDelete = [];
    for (var key in box.keys) {
      if (key.toString().startsWith(HabitStorage.habitStrengthPrefix)) {
        keysToDelete.add(key);
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
    }
    // debugPrint('Cleared ${keysToDelete.length} habit strength records');

    // Clear any remaining keys
    await box.clear();
    // debugPrint('Cleared all remaining data');

    // Compact the box to free up space
    // await box.compact();
    // debugPrint('Compacted database');
  } catch (e) {
    // debugPrint('Error in step-by-step clearing: $e');
    rethrow;
  }
}

/// Alternative method if main clearing fails
Future<bool> _alternativeClearMethod() async {
  try {
    // debugPrint('Attempting alternative clearing method...');

    // Close the box first
    final Box box = Hive.box(HabitStorage.boxName);
    await box.close();
    // debugPrint('Box closed');

    // Delete the box from disk
    await Hive.deleteBoxFromDisk(HabitStorage.boxName);
    // debugPrint('Box deleted from disk');

    // Reopen the box (it will be empty)
    await Hive.openBox(HabitStorage.boxName);
    // debugPrint('New empty box opened');

    return true;
  } catch (e) {
    // debugPrint('Alternative clearing method failed: $e');
    return false;
  }
}

/// Safe function to clear data and restart app
Future<void> clearAppDataAndRestart(BuildContext context) async {
  bool? shouldClear = await _showConfirmationDialog(context);

  if (shouldClear != true) {
    return; // User cancelled
  }

  try {
    // Close any open dialogs first
    // Navigator.of(context).pop();
    // Get.back();

    // Show loading
    _showLoadingDialog(context);

    // Clear the data

    // Clear Firestore data first
    final firestoreService = FirestoreService();
    if (firestoreService.isUserLoggedIn) {
      await firestoreService.deleteAllUserData();
    }

    bool success = await clearAllHabitData();

    // Close loading dialog
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      //   // Get.back();
    }

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data cleared successfully! Restarting app...'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );

      // Wait a bit then restart
      await Future.delayed(const Duration(milliseconds: 1000));
      RestartWidget.restartApp(context);
    } else {
      throw Exception('Failed to clear data');
    }
  } catch (e) {
    // debugPrint('Error in clearAppDataAndRestart: $e');
    // debugPrint('Stack: $stack');

    // Close loading dialog if open
    // Get.back();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to clear data: ${e.toString()}'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Show confirmation dialog
Future<bool?> _showConfirmationDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all habits and settings? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), //Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      );
    },
  );
}

/// Show loading dialog
void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Clearing data...'),
          ],
        ),
      );
    },
  );
}
