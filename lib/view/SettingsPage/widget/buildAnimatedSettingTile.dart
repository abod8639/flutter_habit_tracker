import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildAnimatedSettingTile(
  BuildContext context, {
  required AnimationController animationController,
  required int index,
  required IconData icon,
  required String title,
  required String subtitle,
  required Function()? onTap,
  Widget? trailing,
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
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(icon, color: Theme.of(context).primaryColor),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
          ),
          subtitle: Text(subtitle),
          trailing: trailing,
          onTap: onTap == null
              ? null
              : () {
                  // Apply a scale animation on tap
                  final RenderBox? box =
                      context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    Get.showOverlay(
                      asyncFunction: () async {
                        await Future.delayed(const Duration(milliseconds: 100));
                        onTap();
                      },
                      loadingWidget: const SizedBox(),
                      opacityColor: Colors.transparent,
                      opacity: 0,
                    );
                  } else {
                    onTap();
                  }
                },
        ),
      ),
    ),
  );
}
