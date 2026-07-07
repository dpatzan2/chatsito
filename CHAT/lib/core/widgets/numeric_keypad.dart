import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Decoupled 3x4 numeric keypad. Reports taps via callbacks so it can be
/// reused by any screen (phone entry, OTP, …) without knowing the caller.
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  const NumericKeypad({super.key, required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 6, 30, 28),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 12,
        childAspectRatio: 92 / 52,
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox();
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => k == '⌫' ? onBackspace() : onDigit(k),
              child: Center(
                child: Text(k, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: C.ink)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
