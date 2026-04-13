import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../domain/value_objects/accidental.dart';
import '../../../../domain/value_objects/chord_extension.dart';
import '../chord_input_state.dart';

/// Toggle chips for common chord extensions.
///
/// Multi-select: tapping an active chip removes it, tapping an inactive chip
/// adds it. Calls [onChanged] after each toggle.
class ExtensionPanel extends ConsumerWidget {
  final VoidCallback onChanged;

  const ExtensionPanel({super.key, required this.onChanged});

  static const _extensions = <(String, ChordExtension)>[
    ('7',    ChordExtension(degree: 7)),
    ('maj7', ChordExtension(degree: 7, alteration: null, isAdded: false)),
    ('6',    ChordExtension(degree: 6)),
    ('9',    ChordExtension(degree: 9)),
    ('♭9',   ChordExtension(degree: 9, alteration: Accidental.flat)),
    ('♯9',   ChordExtension(degree: 9, alteration: Accidental.sharp)),
    ('11',   ChordExtension(degree: 11)),
    ('♯11',  ChordExtension(degree: 11, alteration: Accidental.sharp)),
    ('13',   ChordExtension(degree: 13)),
    ('♭13',  ChordExtension(degree: 13, alteration: Accidental.flat)),
    ('add9', ChordExtension(degree: 9, isAdded: true)),
    ('add11',ChordExtension(degree: 11, isAdded: true)),
    ('sus2', ChordExtension(degree: 2)),
    ('sus4', ChordExtension(degree: 4)),
    ('♭5',   ChordExtension(degree: 5, alteration: Accidental.flat)),
    ('♯5',   ChordExtension(degree: 5, alteration: Accidental.sharp)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(chordInputProvider);
    final activeExts = current?.extensions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text('Extensions', style: TextStyle(fontSize: 11, color: Colors.white54)),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _extensions.map(((String, ChordExtension) entry) {
            final (label, ext) = entry;
            final isActive = activeExts.any(
              (e) =>
                  e.degree == ext.degree &&
                  e.alteration == ext.alteration &&
                  e.isAdded == ext.isAdded,
            );
            return GestureDetector(
              onTap: () {
                ref.read(chordInputProvider.notifier).toggleExtension(ext);
                onChanged();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.surface
                        : AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
