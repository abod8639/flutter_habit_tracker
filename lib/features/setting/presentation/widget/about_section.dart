import 'package:flutter/material.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_tile.dart';
import 'package:habit_tracker/generated/l10n.dart';

Widget buildAboutSection(AnimationController animationController) {
  return Column(
    children: [
      AnimatedSettingTile(
        animationController: animationController,
        index: 12,
        icon: Icons.info_outline_rounded,
        title: S.current.about,
        subtitle: S.current.appVersionAndInformation,
        onTap: () {
          // TODO: Implement about page
        },
      ),
    ],
  );
}
