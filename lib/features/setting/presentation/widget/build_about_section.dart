import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/setting/presentation/widget/build_animated_setting_tile.dart';

Widget buildAboutSection(AnimationController animationController) {
  return Builder(
    builder: (context) {
      return Column(
        children: [
          buildAnimatedSettingTile(
            animationController: animationController,
            context,
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
    },
  );
}
