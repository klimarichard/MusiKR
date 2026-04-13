import 'package:freezed_annotation/freezed_annotation.dart';
import 'chord_symbol.dart';

part 'chord_slot.freezed.dart';

/// One of up to four positional chord slots within a bar.
@freezed
class ChordSlot with _$ChordSlot {
  const factory ChordSlot({
    /// 1-based position within the bar (1–4)
    required int position,

    /// The chord occupying this slot; null means the slot is empty.
    ChordSymbol? chord,

    /// Relative horizontal weight within the bar for proportional spacing.
    /// All slots default to 1.0 (equal width).
    @Default(1.0) double weight,
  }) = _ChordSlot;
}
