import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/data/habit_db.dart';

class CompletedHabitsPage extends StatelessWidget {
  final Habitdb habitDb = Habitdb();

  CompletedHabitsPage({super.key}) {
    habitDb.loadData();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> completedHabits = habitDb.getCompletedHabits();

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
        appBar: AppBar(title: Text("Incomplete Habits")),
        body:
            completedHabits.isEmpty == false
                ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: completedHabits.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Text(completedHabits[index]["name"]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
                : Center(child: Text("No incomplete habits found")),
      ),
    );
  }
}


