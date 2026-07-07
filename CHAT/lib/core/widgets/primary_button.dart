import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-width accent pill button used across onboarding and group flows.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final double height;
  const PrimaryButton(this.label, this.onTap, {super.key, this.enabled = true, this.height = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: height,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: C.accent,
          disabledBackgroundColor: const Color(0xFFC9CAD2),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
