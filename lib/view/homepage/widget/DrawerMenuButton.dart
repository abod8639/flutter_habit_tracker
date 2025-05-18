import 'package:flutter/material.dart';

class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Builder(
          builder: (context) {
            return Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.drag_handle),
                    tooltip: 'Open menu',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
