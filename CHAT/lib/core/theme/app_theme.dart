import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Corner radius for chat bubbles (the design's "Redondeado" preset).
const double kBubbleRadius = 18;

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.manropeTextTheme(),
      scaffoldBackgroundColor: C.field,
      colorScheme: ColorScheme.fromSeed(seedColor: C.accent),
    );
  }
}
