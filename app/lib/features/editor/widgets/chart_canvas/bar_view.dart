import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../domain/models/bar.dart';
import '../../../../domain/models/bar_marker.dart';
import '../../../../domain/models/chord_slot.dart';
import '../../../../domain/services/layout_engine.dart';
import 'chord_slot_view.dart';
import 'repeat_bracket_painter.dart';

/// Renders a single [Bar]: background, barlines, chord slots, and marker overlay.
class BarView extends StatelessWidget {
  final Bar bar;
  final BarLayout layout;
  final bool isBarFocused;

  /// 1-based index of the focused slot within this bar, or null.
  final int? focusedSlotIndex;

  /// Called with the 1-based slot position when a slot is tapped.
  final void Function(int slotPosition) onSlotTap;

  const BarView({
    super.key,
    required this.bar,
    required this.layout,
    required this.isBarFocused,
    required this.focusedSlotIndex,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: layout.width,
      height: kBarHeightDp,
      child: Stack(
        children: [
          // 1. Background
          Positioned.fill(
            child: ColoredBox(
              color: isBarFocused && focusedSlotIndex == null
                  ? AppColors.focusHighlight.withAlpha(38)
                  : AppColors.chartPaper,
            ),
          ),

          // 2. Chord slots + barlines
          Row(
            children: [
              _barline(thick: _hasThickLeft),
              ..._buildSlots(),
              _barline(thick: _hasThickRight),
            ],
          ),

          // 3. Repeat bracket / marker overlay
          Positioned.fill(
            child: CustomPaint(
              painter: RepeatBracketPainter(bar.barMarkers),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Slot list
  // ---------------------------------------------------------------------------

  List<Widget> _buildSlots() {
    final slots = bar.chords.isEmpty
        ? [null] // one empty slot spanning the full bar
        : (List<ChordSlot?>.from(bar.chords)
            ..sort((a, b) => (a?.position ?? 0).compareTo(b?.position ?? 0)));

    return slots.map((slot) {
      final position = slot?.position ?? 1;
      final isFocused = isBarFocused && focusedSlotIndex == position;
      final flex = ((slot?.weight ?? 1.0) * 100).round().clamp(1, 400);

      return Expanded(
        flex: flex,
        child: ChordSlotView(
          slot: slot,
          isFocused: isFocused,
          onTap: () => onSlotTap(position),
        ),
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Barlines
  // ---------------------------------------------------------------------------

  bool get _hasThickLeft => bar.barMarkers.any((m) => m is RepeatStart);
  bool get _hasThickRight => bar.barMarkers.any((m) => m is RepeatEnd);

  Widget _barline({required bool thick}) {
    return Container(
      width: thick ? kBarlineThickDp : kBarlineThinDp,
      height: kBarHeightDp,
      color: Colors.black87,
    );
  }
}
