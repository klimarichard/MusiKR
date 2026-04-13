import 'package:freezed_annotation/freezed_annotation.dart';
import 'chord_slot.dart';
import 'bar_marker.dart';
import 'staff_snippet.dart';
import 'ink_layer.dart';

part 'bar.freezed.dart';

@freezed
class Bar with _$Bar {
  const factory Bar({
    required String id,

    /// Up to 4 chord slots; a bar with a single chord has one slot at position 1.
    @Default([]) List<ChordSlot> chords,

    /// When true this bar is split: the first half closes the previous section,
    /// the second half opens the next (pickup / anacrusis pattern).
    @Default(false) bool isSplitBar,

    /// Chord slots for the second half of a split bar.
    @Default([]) List<ChordSlot> splitSlots,

    /// Repeat, navigation, and articulation markers attached to this bar.
    @Default([]) List<BarMarker> barMarkers,

    /// Phase 4 — null until Staff Snippet System is implemented.
    StaffSnippet? staffSnippet,

    /// Phase 3 — null until Ink Annotation Layer is implemented.
    InkLayer? inkLayer,
  }) = _Bar;
}
