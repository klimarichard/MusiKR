import 'package:flutter/material.dart';
import '../../../app/theme/chord_text_styles.dart';
import '../../../domain/models/chord_symbol.dart';
import '../../../domain/value_objects/accidental.dart';
import '../../../domain/value_objects/chord_extension.dart';

/// Renders a [ChordSymbol] as typographically tiered rich text.
///
/// Three tiers:
/// - Root note: large, bold (28 sp)
/// - Accidental + quality: medium (18 sp)
/// - Extensions: small (14 sp)
///
/// Unparsed chords (rawText fallback) render as plain text at 20 sp.
class ChordSymbolText extends StatelessWidget {
  final ChordSymbol chord;
  final Color? color;

  const ChordSymbolText({super.key, required this.chord, this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;

    if (!chord.isParsed) {
      return Text(
        chord.rawText ?? '',
        style: ChordTextStyles.raw.copyWith(color: textColor),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          // 1. Root note
          TextSpan(
            text: chord.root!.displayName,
            style: ChordTextStyles.root.copyWith(color: textColor),
          ),

          // 2. Accidental (superscript, only if not natural)
          if (chord.accidental != Accidental.natural)
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: Transform.translate(
                offset: const Offset(1, 4),
                child: Text(
                  chord.accidental.symbol,
                  style: ChordTextStyles.quality.copyWith(color: textColor),
                ),
              ),
            ),

          // 3. Quality label (empty string for plain major)
          if (chord.quality.label.isNotEmpty)
            TextSpan(
              text: chord.quality.label,
              style: ChordTextStyles.quality.copyWith(color: textColor),
            ),

          // 4. Extensions
          for (final ext in chord.extensions)
            TextSpan(
              text: _extensionLabel(ext),
              style: ChordTextStyles.extension.copyWith(color: textColor),
            ),

          // 5. Slash-chord bass note
          if (chord.bass != null) ...[
            TextSpan(
              text: '/',
              style: ChordTextStyles.quality.copyWith(color: textColor),
            ),
            TextSpan(
              text: chord.bass!.displayName,
              style: ChordTextStyles.quality.copyWith(color: textColor),
            ),
            if (chord.bassAccidental != null)
              TextSpan(
                text: chord.bassAccidental!.symbol,
                style: ChordTextStyles.extension.copyWith(color: textColor),
              ),
          ],
        ],
      ),
    );
  }

  String _extensionLabel(ChordExtension ext) {
    final prefix = ext.isAdded ? 'add' : '';
    final acc = ext.alteration?.symbol ?? '';
    return '$prefix$acc${ext.degree}';
  }
}
