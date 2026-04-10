import 'package:flutter/material.dart';
import '../theme/tavern_theme.dart';

abstract final class TavernSnackbar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? TavernColors.error : TavernColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    show(context, message, isError: true);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message);
  }
}
