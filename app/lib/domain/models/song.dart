import 'package:freezed_annotation/freezed_annotation.dart';
import 'metadata.dart';
import 'section.dart';
import 'ink_layer.dart';

part 'song.freezed.dart';

/// The top-level aggregate root for a MusiKR chart.
@freezed
class Song with _$Song {
  const factory Song({
    required String id,
    required Metadata metadata,
    @Default([]) List<Section> sections,

    /// Phase 3 — free-floating ink that is not scoped to any bar or section.
    InkLayer? globalInkLayer,
  }) = _Song;
}
