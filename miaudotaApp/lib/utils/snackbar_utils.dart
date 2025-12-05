import 'package:flutter/material.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message) {
    _show(context, message, const Color(0xFFB00020)); // vermelho erro
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, const Color(0xFF1B5E20)); // verde sucesso
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, const Color(0xFF243B58)); // azul info (Miaudota)
  }

  static void _show(BuildContext context, String message, Color color) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars(); // evita empilhar vários snackbars

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(milliseconds: 2400),
      ),
    );
  }
}
