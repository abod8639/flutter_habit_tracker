import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildAnimatedSettingLang(
  BuildContext context, {
  required AnimationController animationController,
  required int index,
  required IconData icon,
  required String currentValue,
  required List<DropdownMenuEntry<String>> entries,
  required Function(String?) onChanged,
  Color? textColor,
}) {
  final Animation<double> animation = CurvedAnimation(
    parent: animationController,
    curve: Interval(
      0.05 * (index % 10),
      math.min(0.05 * (index % 10) + 0.5, 1.0),
      curve: Curves.easeOut,
    ),
  );

  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(animation),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: currentValue,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  dropdownColor: Theme.of(context).cardColor,
                  items: entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.value,
                          child: Text(entry.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    Get.showOverlay(
                      asyncFunction: () async {
                        await Future.delayed(const Duration(milliseconds: 100));
                        onChanged(value);
                      },
                      loadingWidget: const SizedBox(),
                      opacityColor: Colors.transparent,
                      opacity: 0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
