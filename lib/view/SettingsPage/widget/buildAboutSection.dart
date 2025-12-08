import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSettingTile.dart';

Widget buildAboutSection(AnimationController _animationController) {
    return Builder(
      builder: (context) {
        return Column(
          children: [

            buildAnimatedSettingTile(
              animationController: _animationController,
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
      }
    );
  }