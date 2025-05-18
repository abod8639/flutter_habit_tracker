import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/view/homepage/HomeScreen.dart';

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, this.error = 'Failed to initialize app'});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'An error occurred',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.offAll(HomeScreen()),
                child: Text("Restart"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
