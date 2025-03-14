import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/page/ThemePage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('This is the settings page.'),
            ListTile(
              title: Row(
                children: [
                  const Icon(Icons.color_lens),
                  const SizedBox(width: 10),
                  const Text('Change Theme'),
                ],
              ),
              onTap: (){
                Get.to(const ThemePage());
              },
            )
          ],
        ),
      ),
    );
    
  }
}