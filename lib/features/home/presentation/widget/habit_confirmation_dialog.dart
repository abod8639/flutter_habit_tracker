import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

class HabitConfirmationDialog extends StatefulWidget {
  final List<String> extractedHabits;

  const HabitConfirmationDialog({required this.extractedHabits, super.key});

  @override
  HabitConfirmationDialogState createState() => HabitConfirmationDialogState();
}

class HabitConfirmationDialogState extends State<HabitConfirmationDialog> {
  final Map<int, bool> _selectedHabits = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.extractedHabits.length; i++) {
      _selectedHabits[i] = true;
    }
  }

  void _saveSelectedHabits() {
    final c = Get.find<HabitController>();
    final selectedHabits = <String>[];
    for (int i = 0; i < widget.extractedHabits.length; i++) {
      if (_selectedHabits[i] == true) {
        selectedHabits.add(widget.extractedHabits[i]);
      }
    }
    
    if (selectedHabits.isNotEmpty) {
      c.addMultipleHabits(selectedHabits);
    }
    
    Navigator.of(context).pop(); // Close the confirmation dialog
    Get.snackbar(
      S.current.success,
      'Added the selected habits successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.extractedHabits.isEmpty) {
      return AlertDialog(
        title: const Text('No Habits Detected'),
        content: const Text(
          'We could not find any clear tasks or habits in this image. Please try another one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Detected Habits'),
      contentPadding: const EdgeInsets.only(top: 16, bottom: 0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: widget.extractedHabits.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return CheckboxListTile(
              activeColor: colorScheme.primary,
              title: Text(widget.extractedHabits[index]),
              value: _selectedHabits[index],
              onChanged: (bool? value) {
                setState(() {
                  _selectedHabits[index] = value ?? false;
                });
              },
            );
          },
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          onPressed: _saveSelectedHabits,
          child: const Text('Save Selected'),
        ),
      ],
    );
  }
}
