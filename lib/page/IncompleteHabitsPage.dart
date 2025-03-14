import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/data/habit_db.dart';

class IncompleteHabitsPage extends StatelessWidget {
  final Habitdb habitDb = Habitdb();

  IncompleteHabitsPage({super.key}) {
    habitDb.loadData();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> incompleteHabits = habitDb.getIncompleteHabits();

    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event.isKeyPressed(LogicalKeyboardKey.escape) ||
            event.isKeyPressed(LogicalKeyboardKey.backspace)) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Incomplete Habits")),
        body: incompleteHabits.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: incompleteHabits.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Text(incompleteHabits[index]["name"]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(
                child: Text("No Incomplete Habits Found Today"),
              ),
      ),
    );
  }
}