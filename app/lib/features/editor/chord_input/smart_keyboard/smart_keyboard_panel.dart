import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/editor_providers.dart';
import '../chord_input_state.dart';
import 'bass_note_selector.dart';
import 'extension_panel.dart';
import 'quality_selector.dart';
import 'root_selector.dart';

/// The full smart keyboard: root → quality → extensions → bass note.
///
/// Every user interaction immediately commits the current [ChordSymbol] to the
/// focused slot via [EditorNotifier.updateChord].
class SmartKeyboardPanel extends ConsumerWidget {
  final String songId;

  const SmartKeyboardPanel({super.key, required this.songId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RootSelector(onChanged: () => _commit(ref)),
          const SizedBox(height: 12),
          QualitySelector(onChanged: () => _commit(ref)),
          const SizedBox(height: 12),
          ExtensionPanel(onChanged: () => _commit(ref)),
          const SizedBox(height: 12),
          BassNoteSelector(onChanged: () => _commit(ref)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Reads the current partial chord and the focused slot, then fires
  /// [EditorNotifier.updateChord].
  void _commit(WidgetRef ref) {
    final chord = ref.read(chordInputProvider);
    if (chord == null) return;

    final editorState = ref.read(editorProvider(songId)).valueOrNull;
    if (editorState == null) return;

    final barId = editorState.focusedBarId;
    final slotPos = editorState.focusedSlotIndex ?? 1;
    if (barId == null) return;

    // Find the sectionId for this bar.
    final sectionId = _sectionIdFor(editorState.song.sections
        .expand((s) => s.bars.map((b) => (s.id, b.id)))
        .toList(), barId);
    if (sectionId == null) return;

    ref.read(editorProvider(songId).notifier).updateChord(
          sectionId: sectionId,
          barId: barId,
          slotPosition: slotPos,
          chord: chord,
        );
  }

  String? _sectionIdFor(
    List<(String, String)> sectionBarPairs,
    String barId,
  ) {
    for (final (sId, bId) in sectionBarPairs) {
      if (bId == barId) return sId;
    }
    return null;
  }
}
