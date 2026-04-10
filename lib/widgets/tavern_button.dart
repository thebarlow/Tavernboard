import 'package:flutter/material.dart';

enum TavernButtonVariant { primary, secondary, danger }

class TavernButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TavernButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const TavernButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TavernButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
              )
            : Text(label);

    switch (variant) {
      case TavernButtonVariant.primary:
        return ElevatedButton(onPressed: isLoading ? null : onPressed, child: child);
      case TavernButtonVariant.secondary:
        return OutlinedButton(onPressed: isLoading ? null : onPressed, child: child);
      case TavernButtonVariant.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
          ),
          child: child,
        );
    }
  }
}
