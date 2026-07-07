

import 'package:flutter/material.dart';

/// Circular initials avatar with an optional corner badge.
class Avatar extends StatelessWidget {
  final String text;
  final Color color;
  final double size, fontSize;
  final Widget? badge;
  const Avatar(this.text, this.color, {super.key, this.size = 54, this.fontSize = 18, this.badge});

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size, height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: Colors.white)),
    );
    if (badge == null) return circle;
    return Stack(clipBehavior: Clip.none, children: [
      circle,
      Positioned(bottom: -1, right: -1, child: badge!),
    ]);
  }
}
