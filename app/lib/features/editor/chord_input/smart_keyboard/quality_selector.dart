import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../domain/value_objects/chord_quality.dart';
import '../chord_input_state.dart';

/// A wrap of chips covering all [ChordQuality] variants.
///
/// The currently selected quality is highlighted. Tapping a chip calls
/// [ChordInputNotifier.setQuality] then [onChanged] so the parent can
/// forward the chord to the editor.
class QualitySelector extends ConsumerWidget {
  final VoidCallback onChanged;

  const QualitySelector({super.key, required this.onChanged});

  // Display labels for qualities where the enum label alone is ambiguous.
  static const _displayLabels = <ChordQuality, String>{
    ChordQuality.major: 'maj',
    ChordQuality.power: '5',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(chordInputProvider);
    final selectedQuality = current?.quality;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text('Quality', style: TextStyle(fontSize: 11, color: Colors.white54)),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: ChordQuality.values.map((q) {
            final label = _displayLabels[q] ?? q.label;
            final isSelected = q == selectedQuality;
            return GestureDetector(
              onTap: () {
                ref.read(chordInputProvider.notifier).setQuality(q);
                onChanged();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label.isEmpty ? 'maj' : label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
