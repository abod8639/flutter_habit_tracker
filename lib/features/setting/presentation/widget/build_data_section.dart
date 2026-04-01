import 'package:flutter/material.dart';
import 'package:habit_tracker/functions/clear_all_habit_data.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/setting/presentation/widget/build_animated_setting_tile.dart';

Widget buildDataSection(AnimationController animationController) {
  return Builder(
    builder: (context) {
      return Column(
        children: [
          buildAnimatedSettingTile(
            animationController: animationController,
            context,
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
