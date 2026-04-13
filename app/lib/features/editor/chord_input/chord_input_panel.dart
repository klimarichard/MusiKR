import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../state/editor_providers.dart';
import '../../../domain/value_objects/chord_input_mode.dart';
import 'chord_input_state.dart';
import 'smart_keyboard/smart_keyboard_panel.dart';
import 'text_input/text_chord_panel.dart';

/// Bottom sheet that hosts the chord input UI.
///
/// Switches between [SmartKeyboardPanel] and [TextChordPanel] based on the
/// editor's current [ChordInputMode]. Includes a drag handle, a mode tab bar,
/// and a "Clear" button to erase the focused chord.
class ChordInputPanel extends ConsumerWidget {
  final String songId;

  const ChordInputPanel({super.key, required this.songId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorAsync = ref.watch(editorProvider(songId));
    final inputMode =
        editorAsync.valueOrNull?.inputMode ?? ChordInputMode.smartKeyboard;
    final notifier = ref.read(editorProvider(songId).notifier);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Mode toggle + clear button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Tab-style toggle
                _ModeToggle(
                  current: inputMode,
                  onChanged: notifier.setInputMode,
                ),
                const Spacer(),
                // Clear chord
                TextButton.icon(
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                  ),
                  onPressed: () => _clearChord(ref),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white12),

          // Input panel
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: inputMode == ChordInputMode.smartKeyboard
                ? SmartKeyboardPanel(songId: songId)
                : TextChordPanel(songId: songId),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _clearChord(WidgetRef ref) {
    ref.read(chordInputProvider.notifier).reset();

    final editorState = ref.read(editorProvider(songId)).valueOrNull;
    if (editorState == null) return;
    final barId = editorState.focusedBarId;
    final slotPos = editorState.focusedSlotIndex ?? 1;
    if (barId == null) return;

    final sectionId = editorState.song.sections
        .where((s) => s.bars.any((b) => b.id == barId))
        .map((s) => s.id)
        .firstOrNull;
    if (sectionId == null) return;

    ref.read(editorProvider(songId).notifier).updateChord(
          sectionId: sectionId,
          barId: barId,
          slotPosition: slotPos,
          chord: null,
        );
  }
}

class _ModeToggle extends StatelessWidget {
  final ChordInputMode current;
  final void Function(ChordInputMode) onChanged;

  const _ModeToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tab('Smart', ChordInputMode.smartKeyboard),
        const SizedBox(width: 4),
        _tab('Text', ChordInputMode.text),
      ],
    );
  }

  Widget _tab(String label, ChordInputMode mode) {
    final selected = current == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.surface : Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
