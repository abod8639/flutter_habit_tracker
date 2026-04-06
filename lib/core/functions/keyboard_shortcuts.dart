import 'package:flutter/services.dart';
import 'package:get/get.dart';

void keyboardShortCutsPages(KeyEvent event) {
  if (event.physicalKey == PhysicalKeyboardKey.numLock) {
    return;
  }
  if (event.logicalKey == LogicalKeyboardKey.escape ||
      event.logicalKey == LogicalKeyboardKey.backspace) {
    Get.back();
  }
}
