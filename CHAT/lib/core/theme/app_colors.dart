import 'package:flutter/material.dart';

/// Design tokens (palette) for Chatsito. Mirrors the source design's colors.
class C {
  static const accent = Color(0xFF7C5CFF);
  static const ink = Color(0xFF15131F);
  static const sub = Color(0xFF6B6E7B);
  static const muted = Color(0xFF9A9DA8);
  static const faint = Color(0xFFA8AAB4);
  static const hair = Color(0xFFF1F1F4);
  static const line = Color(0xFFEAEBEF);
  static const field = Color(0xFFF4F5F7);
  static const fieldAlt = Color(0xFFFAFAFB);
  static const border = Color(0xFFE6E7EC);
  static const canvas = Color(0xFFE9EAEF);
  static const bezel = Color(0xFF0E0E14);
  static const green = Color(0xFF1FA971);
  static const danger = Color(0xFFE5484D);
  static const arrow = Color(0xFFC7CAD3);

  /// color-mix(in oklch, accent, white p%) — srgb approximation.
  static Color tint(double whitePct) => Color.lerp(accent, Colors.white, whitePct / 100)!;

  /// color-mix(in oklch, accent, transparent p%).
  static Color aOpacity(double transparentPct) => accent.withValues(alpha: 1 - transparentPct / 100);
}
