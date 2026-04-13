import 'package:flutter/material.dart';

/// TextStyle constants for the three tiers of chord symbol typography.
///
/// All tiers use the system font. Leland/LelandText are reserved for
/// staff notation glyphs rendered by CustomPainter, not for chord text.
abstract final class ChordTextStyles {
  /// Root note letter — largest, heaviest weight.
  static const TextStyle root = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  /// Quality suffix and accidental superscript — medium size.
  static const TextStyle quality = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// Extension suffixes (9, b9, #11, add9 …) — smallest tier.
  static const TextStyle extension = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  /// Raw / unparsed chord text — used when ChordParser falls back to rawText.
  static const TextStyle raw = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
}
