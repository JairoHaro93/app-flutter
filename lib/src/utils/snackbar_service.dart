import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, warning, error }

class SnackbarService {
  static void show(
    String title,
    String message, {
    SnackbarType type = SnackbarType.success,
  }) {
    final Color bgColor;
    final IconData icon;

    switch (type) {
      case SnackbarType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case SnackbarType.warning:
        bgColor = Colors.amber;
        icon = Icons.warning;
        break;
      case SnackbarType.error:
        bgColor = Colors.red;
        icon = Icons.error;
        break;
    }

    Get.snackbar(
      title,
      message,
      icon: Icon(icon, color: Colors.white),
      backgroundColor: bgColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  static void success(String message) {
    show('Éxito', message, type: SnackbarType.success);
  }

  static void warning(String message) {
    show('Advertencia', message, type: SnackbarType.warning);
  }

  static void error(String message) {
    show('Error', message, type: SnackbarType.error);
  }
}
