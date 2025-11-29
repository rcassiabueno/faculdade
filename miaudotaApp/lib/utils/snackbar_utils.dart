import 'package:flutter/material.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message) {
    _show(context, message, const Color(0xFFB00020)); // vermelho erro
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, const Color(0xFF1B5E20)); // verde sucesso
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message,
      const Color(0xFF243B58),
    ); // azul info (igual do Miaudota)
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
