import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../domain/models/chord_slot.dart';
import '../chord_symbol_text.dart';

/// A single tappable chord slot within a bar.
///
/// Shows [ChordSymbolText] when the slot has a chord, a faint "+" icon when
/// focused but empty, and nothing when unfocused and empty.
class ChordSlotView extends StatefulWidget {
  final ChordSlot? slot;
  final bool isFocused;
  final VoidCallback onTap;

  const ChordSlotView({
    super.key,
    required this.slot,
    required this.isFocused,
    required this.onTap,
  });

  @override
  State<ChordSlotView> createState() => _ChordSlotViewState();
}

class _ChordSlotViewState extends State<ChordSlotView> {
  bool _debugTapped = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (_debugTapped) {
      bg = Colors.red.withAlpha(128);
    } else if (widget.isFocused) {
      bg = AppColors.focusHighlight.withAlpha(64);
    } else {
      bg = Colors.transparent;
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        setState(() => _debugTapped = true);
        widget.onTap();
      },
      child: Container(
        height: kBarHeightDp,
        color: bg,
        alignment: Alignment.center,
        child: _content(),
      ),
    );
  }

  Widget? _content() {
    final chord = widget.slot?.chord;
    if (chord != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChordSymbolText(chord: chord, color: Colors.black87),
      );
    }
    if (widget.isFocused) {
      return const Icon(Icons.add, size: 18, color: Colors.black38);
    }
    return null;
  }
}
