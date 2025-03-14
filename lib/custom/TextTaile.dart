import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart';

class TextTaile extends StatelessWidget {
  
  final String Habitname;
  final bool HabitCombleted;
  final Function(BuildContext)? onDelete;
  final Function(BuildContext)? onEdit;
  final Function(bool?)? onChanged;
  final Function()? onTap;
  const TextTaile({
    required this.HabitCombleted,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
    required this.Habitname,
    super.key,
  });

  // bool HabitCombleted = false;
  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Slidable(
        direction: Axis.horizontal,
        startActionPane: ActionPane(
          // dragDismissible: false,
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              spacing: 5,
              autoClose: true,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Theme.of(context).colorScheme.error,
              onPressed: onDelete,
              icon: Icons.delete,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              autoClose: true,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.orange[700]!,
              onPressed: onEdit,
              icon: Icons.edit,
            ),
          ],
        ),
        child: GetBuilder<HabitController>(
          init: HabitController(),
          builder:
              (controller) => ListTile(
                splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
                focusColor: Theme.of(
                  context,
                ).colorScheme.secondary.withOpacity(0.5),
                onTap: onTap,
                title: Container(
                  decoration: BoxDecoration(
                    color:
                        controller.db.todaysHabitList[controller.index!][1] ==
                                true
                            ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.5)
                            : themeColors == Colors.white
                            ? Colors.grey[700]
                            : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        checkColor: const Color.fromARGB(255, 255, 255, 255),
                        value: HabitCombleted,
                        onChanged: onChanged,
                      ),
                      Expanded(
                        child: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: themeColors.onSurface,
                            // color: HabitCombleted ? Colors.grey[800] : Colors.white,
                            inherit: false,
                            decoration:
                                HabitCombleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                          Habitname,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
