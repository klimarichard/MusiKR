import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../widgets/chord_symbol_text.dart';

/// Displays a live [ChordSymbolText] preview of the current text input.
///
/// Passes the raw text through [ChordParser] on every rebuild and renders
/// the result. When the text is empty or unparseable, shows a placeholder.
class ChordPreviewWidget extends ConsumerWidget {
  final String text;

  const ChordPreviewWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (text.trim().isEmpty) {
      return const Text(
        'Type a chord…',
        style: TextStyle(color: Colors.white38, fontSize: 20),
      );
    }

    final parser = ref.read(chordParserProvider);
    final chord = parser.parse(text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chartPaper,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ChordSymbolText(chord: chord, color: Colors.black87),
    );
  }
}
