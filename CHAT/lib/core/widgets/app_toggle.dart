import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// iOS-style switch used in settings rows.
class AppToggle extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  const AppToggle(this.value, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48, height: 29,
        padding: const EdgeInsets.all(2),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? C.accent : const Color(0xFFD4D6DE),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 25, height: 25,
          decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))],
          ),
        ),
      ),
    );
  }
}
