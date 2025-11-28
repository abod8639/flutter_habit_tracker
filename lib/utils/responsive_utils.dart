import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000.0;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600.0 &&
      MediaQuery.of(context).size.width < 1000.0;

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600.0;
}
