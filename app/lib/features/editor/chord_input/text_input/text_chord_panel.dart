import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../state/editor_providers.dart';
import 'chord_preview_widget.dart';

/// A text field with a live [ChordPreviewWidget] for typing chord symbols.
///
/// Pressing Enter or tapping "Apply" commits the parsed chord to the focused
/// slot via [EditorNotifier.updateChord].
class TextChordPanel extends ConsumerStatefulWidget {
  final String songId;

  const TextChordPanel({super.key, required this.songId});

  @override
  ConsumerState<TextChordPanel> createState() => _TextChordPanelState();
}

class _TextChordPanelState extends ConsumerState<TextChordPanel> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live preview
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) =>
                ChordPreviewWidget(text: _ctrl.text),
          ),
          const SizedBox(height: 12),
          // Text field
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.onSurface, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g.  Cmaj7  /  G7/B  /  Dm7b5',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54),
                onPressed: () => _ctrl.clear(),
              ),
            ),
            onSubmitted: (_) => _apply(),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _apply,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.surface,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _apply() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final chord = ref.read(chordParserProvider).parse(text);
    final editorState =
        ref.read(editorProvider(widget.songId)).valueOrNull;
    if (editorState == null) return;

    final barId = editorState.focusedBarId;
    final slotPos = editorState.focusedSlotIndex ?? 1;
    if (barId == null) return;

    final sectionId = editorState.song.sections
        .where((s) => s.bars.any((b) => b.id == barId))
        .map((s) => s.id)
        .firstOrNull;
    if (sectionId == null) return;

    ref.read(editorProvider(widget.songId).notifier).updateChord(
          sectionId: sectionId,
          barId: barId,
          slotPosition: slotPos,
          chord: chord,
        );

    _ctrl.clear();
  }
}
