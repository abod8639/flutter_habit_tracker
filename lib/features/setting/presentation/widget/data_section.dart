import 'package:flutter/material.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_tile.dart';
import 'package:habit_tracker/core/functions/clear_all_habit_data.dart';
import 'package:habit_tracker/generated/l10n.dart';

Widget buildDataSection(AnimationController animationController) {
  return Builder(
    builder: (context) {
      return Column(
        children: [
          AnimatedSettingTile(
            animationController: animationController,
            index: 10,
            icon: Icons.delete_sweep_rounded,
            title: S.current.clearAllData,
            subtitle: S.current.deleteAllHabitsAndSettings,
            textColor: Colors.red,
            onTap: () => clearAppDataAndRestart(context),
          ),
        ],
      );
    },
  );
}
