
import 'package:flutter/material.dart';
class MyListTile extends StatelessWidget {
  final Icon icon;
  final String title;
  final Function()? onTap;

  const MyListTile({
    this.onTap,
    this.icon = const Icon(Icons.check),
    this.title = "Completed Habit",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        focusColor: Theme.of(context).colorScheme.secondary .withOpacity(0.5) ,
        splashColor: Theme.of(context).primaryColor.withOpacity(0.3),

        shape: RoundedRectangleBorder(),
        onTap: onTap,
         // Get.back();
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Expanded(child: Text(title)), icon],
        ),
      ),
    );
  }
}
