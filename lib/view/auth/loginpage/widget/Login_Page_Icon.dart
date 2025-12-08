
import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

class LoginPageIcon extends StatelessWidget {
  final ThemeData theme;
  const LoginPageIcon({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: theme.colorScheme.primary,
        ),

        const SizedBox(height: 16),
        Text(
          'Habit Tracker',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          S.current.login,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
