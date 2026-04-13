import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../domain/value_objects/accidental.dart';
import '../../../../domain/value_objects/note_name.dart';
import '../chord_input_state.dart';

/// Row of root-note buttons (C–B) with a ♭ / ♮ / ♯ accidental modifier.
///
/// Tapping a root immediately commits it via [ChordInputNotifier.setRoot].
/// The caller is responsible for forwarding the updated chord to the editor.
class RootSelector extends ConsumerStatefulWidget {
  /// Called after root is selected so the parent can commit to the editor.
  final VoidCallback onChanged;

  const RootSelector({super.key, required this.onChanged});

  @override
  ConsumerState<RootSelector> createState() => _RootSelectorState();
}

class _RootSelectorState extends ConsumerState<RootSelector> {
  Accidental _accidental = Accidental.natural;

  static const _notes = NoteName.values; // C D E F G A B

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(chordInputProvider);
    final selectedRoot = current?.root;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accidental modifier
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text('Root', style: TextStyle(fontSize: 11, color: Colors.white54)),
            ),
            _accidentalButton(Accidental.flat, '♭'),
            const SizedBox(width: 4),
            _accidentalButton(Accidental.natural, '♮'),
            const SizedBox(width: 4),
            _accidentalButton(Accidental.sharp, '♯'),
          ],
        ),
        const SizedBox(height: 6),
        // Root note buttons
        Row(
          children: _notes.map((note) {
            final isSelected = note == selectedRoot &&
                current?.accidental == _accidental;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _NoteButton(
                  label: note.displayName,
                  selected: isSelected,
                  onTap: () {
                    ref
                        .read(chordInputProvider.notifier)
                        .setRoot(note, _accidental);
                    widget.onChanged();
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _accidentalButton(Accidental acc, String label) {
    final selected = _accidental == acc;
    return GestureDetector(
      onTap: () => setState(() => _accidental = acc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.surface : AppColors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NoteButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NoteButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.surface : AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
