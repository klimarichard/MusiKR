import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../domain/value_objects/accidental.dart';
import '../../../../domain/value_objects/note_name.dart';
import '../chord_input_state.dart';

/// Optional slash-chord bass note picker.
///
/// Shows a "None" chip and 7 note buttons (C–B) with a ♭/♯ modifier.
/// Tapping "None" clears the bass note; tapping a note sets it.
class BassNoteSelector extends ConsumerStatefulWidget {
  final VoidCallback onChanged;

  const BassNoteSelector({super.key, required this.onChanged});

  @override
  ConsumerState<BassNoteSelector> createState() => _BassNoteSelectorState();
}

class _BassNoteSelectorState extends ConsumerState<BassNoteSelector> {
  Accidental _accidental = Accidental.natural;

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(chordInputProvider);
    final selectedBass = current?.bass;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text('Bass note (slash chord)',
              style: TextStyle(fontSize: 11, color: Colors.white54)),
        ),
        Row(
          children: [
            // None chip
            GestureDetector(
              onTap: () {
                ref.read(chordInputProvider.notifier).setBass(null, null);
                widget.onChanged();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedBass == null
                      ? AppColors.accent
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'None',
                  style: TextStyle(
                    color: selectedBass == null
                        ? AppColors.surface
                        : AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Accidental modifier
            _accidentalButton(Accidental.flat, '♭'),
            const SizedBox(width: 4),
            _accidentalButton(Accidental.natural, '♮'),
            const SizedBox(width: 4),
            _accidentalButton(Accidental.sharp, '♯'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: NoteName.values.map((note) {
            final isSelected = note == selectedBass;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(chordInputProvider.notifier)
                        .setBass(note, _accidental);
                    widget.onChanged();
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      note.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.surface : AppColors.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
