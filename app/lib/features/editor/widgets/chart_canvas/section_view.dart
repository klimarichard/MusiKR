import 'package:flutter/material.dart';
import '../../../../domain/models/section.dart';
import '../../../../domain/services/layout_engine.dart';
import '../section_header.dart';
import 'bar_view.dart';

/// Renders a [Section]: its header band followed by rows of [BarView]s.
class SectionView extends StatelessWidget {
  final Section section;

  /// Pre-computed layout rows for this section from [LayoutEngine].
  final List<LayoutRow> rows;

  final String? focusedBarId;
  final int? focusedSlotIndex;

  /// Called with (barId, 1-based slotPosition) when a slot is tapped.
  final void Function(String barId, int slotPosition) onSlotTap;

  final VoidCallback onSectionTap;

  const SectionView({
    super.key,
    required this.section,
    required this.rows,
    required this.focusedBarId,
    required this.focusedSlotIndex,
    required this.onSlotTap,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(section: section, onTap: onSectionTap),
        for (final row in rows)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row.bars.map((barLayout) {
              final bar = section.bars.firstWhere(
                (b) => b.id == barLayout.barId,
              );
              return BarView(
                bar: bar,
                layout: barLayout,
                isBarFocused: bar.id == focusedBarId,
                focusedSlotIndex:
                    bar.id == focusedBarId ? focusedSlotIndex : null,
                onSlotTap: (pos) => onSlotTap(bar.id, pos),
              );
            }).toList(),
          ),
      ],
    );
  }
}
