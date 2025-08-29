import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, warning, error }

class SnackbarService {
  static String? _lastMessage;
  static DateTime? _lastShownAt;

  static void show(
    String title,
    String message, {
    SnackbarType type = SnackbarType.success,
    // extras opcionales:
    String? actionLabel,
    VoidCallback? onAction,
    bool closeCurrent = true,
  }) {
    // Evita duplicados seguidos (misma cadena en < 1s)
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastMessage = message;
    _lastShownAt = now;

    final Color bgColor;
    final IconData icon;
    final SnackPosition position;

    switch (type) {
      case SnackbarType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle;
        position = SnackPosition.BOTTOM;
        break;
      case SnackbarType.warning:
        bgColor = Colors.amber[800]!;
        icon = Icons.warning_amber_rounded;
        position = SnackPosition.BOTTOM;
        break;
      case SnackbarType.error:
        bgColor = Colors.red[700]!;
        icon = Icons.error_outline;
        // a veces es más visible arriba para errores:
        position = SnackPosition.TOP;
        break;
    }

    if (closeCurrent && Get.isSnackbarOpen) {
      Get.back(); // cierra el snackbar activo
    }

    Get.snackbar(
      title,
      message,
      icon: Icon(icon, color: Colors.white),
      backgroundColor: bgColor,
      colorText: Colors.white,
      snackPosition: position,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      barBlur: 2,
      isDismissible: true,
      duration: const Duration(seconds: 3),
      // Limita el ancho en tablets/desktop para que no se vea demasiado ancho
      maxWidth: Get.width > 600 ? 520 : null,
      mainButton:
          (actionLabel != null && onAction != null)
              ? TextButton(
                onPressed: () {
                  Get.back(); // cierra el snackbar
                  onAction();
                },
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
      // Evita que el teclado tape el snackbar
      shouldIconPulse: false,
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }

  static void success(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      'Éxito',
      message,
      type: SnackbarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void warning(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      'Advertencia',
      message,
      type: SnackbarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      'Error',
      message,
      type: SnackbarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
