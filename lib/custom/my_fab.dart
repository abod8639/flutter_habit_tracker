import 'package:flutter/material.dart';

class myfloatingActionButton extends StatelessWidget {
  final Function()? onPressed;
  const myfloatingActionButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      autofocus: true,
      focusColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      isExtended: true,
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: onPressed,
      splashColor: Theme.of(context).colorScheme.primary,
      child: const Icon(size: 25, color: Colors.black87, Icons.add),
    );
  }
}
