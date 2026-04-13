import 'package:flutter/material.dart';

/// Semantic colour tokens for MusiKR.
///
/// Chart surface colours are tuned to read well as "music paper".
/// App chrome colours are dark to frame the chart without distraction.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Chart surface
  // ---------------------------------------------------------------------------

  /// Cream background — the "paper" colour of every bar.
  static const Color chartPaper = Color(0xFFF5F0E8);

  /// Barline and divider colour on the chart.
  static const Color chartLines = Color(0xFFCCC5B5);

  /// Amber highlight for the currently focused bar or slot.
  static const Color focusHighlight = Color(0xFFFFD166);

  /// Slightly darker cream for section header bands.
  static const Color sectionBand = Color(0xFFEDE8DC);

  // ---------------------------------------------------------------------------
  // App chrome (dark)
  // ---------------------------------------------------------------------------

  /// Primary dark background (app bars, panels).
  static const Color surface = Color(0xFF1A1A2E);

  /// Slightly lighter dark surface for chord input panel.
  static const Color surfaceVariant = Color(0xFF252540);

  /// Primary text/icon colour on dark surfaces.
  static const Color onSurface = Color(0xFFE8E8F0);

  /// Accent — same amber as focusHighlight; used for active chips/buttons.
  static const Color accent = Color(0xFFFFD166);

  /// Error / destructive action colour.
  static const Color error = Color(0xFFEF476F);
}
