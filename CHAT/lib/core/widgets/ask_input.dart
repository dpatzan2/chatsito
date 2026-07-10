import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Dialog con un TextField; [onSubmit] devuelve null si fue bien o el error a mostrar.
void askInput(BuildContext context,
    {required String title, required String hint, required String action,
    required TextInputType keyboard, required Future<String?> Function(String) onSubmit}) {
  final field = TextEditingController();
  String? error;
  bool busy = false;
  showDialog(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (dialog, setState) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.ink)),
        content: TextField(
          controller: field, autofocus: true, keyboardType: keyboard,
          decoration: InputDecoration(hintText: hint, errorText: error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: busy ? null : () async {
              if (field.text.trim().isEmpty) return;
              setState(() => busy = true);
              final err = await onSubmit(field.text.trim());
              if (!dialog.mounted) return;
              if (err == null) {
                Navigator.pop(dialog);
              } else {
                setState(() { error = err; busy = false; });
              }
            },
            child: Text(action, style: const TextStyle(fontWeight: FontWeight.w700, color: C.accent)),
          ),
        ],
      ),
    ),
  );
}
