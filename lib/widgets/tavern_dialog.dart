import 'package:flutter/material.dart';
import 'tavern_button.dart';

class TavernDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String saveLabel;
  final VoidCallback onSave;
  final bool isSaving;

  const TavernDialog({
    super.key,
    required this.title,
    required this.content,
    this.saveLabel = 'Save',
    required this.onSave,
    this.isSaving = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String saveLabel = 'Save',
    required VoidCallback onSave,
    bool isSaving = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (_) => TavernDialog(
        title: title,
        content: content,
        saveLabel: saveLabel,
        onSave: onSave,
        isSaving: isSaving,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        TavernButton(
          label: 'Cancel',
          variant: TavernButtonVariant.secondary,
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
        ),
        TavernButton(
          label: saveLabel,
          onPressed: onSave,
          isLoading: isSaving,
        ),
      ],
    );
  }
}
