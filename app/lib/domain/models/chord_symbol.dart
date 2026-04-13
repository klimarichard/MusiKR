import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/note_name.dart';
import '../value_objects/accidental.dart';
import '../value_objects/chord_quality.dart';
import '../value_objects/chord_extension.dart';

part 'chord_symbol.freezed.dart';

/// A fully-parsed or partially-parsed chord symbol.
///
/// When [root] is non-null, the chord was successfully parsed.
/// When [root] is null, [rawText] holds the verbatim user input and the
/// chord is rendered as-is (satisfies the "every chord must be writable" rule).
@freezed
class ChordSymbol with _$ChordSymbol {
  const ChordSymbol._();

  const factory ChordSymbol({
    NoteName? root,
    @Default(Accidental.natural) Accidental accidental,
    @Default(ChordQuality.major) ChordQuality quality,
    @Default([]) List<ChordExtension> extensions,
    NoteName? bass,
    Accidental? bassAccidental,
    /// Non-null when the parser could not fully interpret the input.
    String? rawText,
  }) = _ChordSymbol;

  /// Creates a chord symbol from unparsed user text (fallback / escape hatch).
  factory ChordSymbol.raw(String text) => ChordSymbol(rawText: text);

  /// True when the chord was successfully parsed to structured data.
  bool get isParsed => root != null;
}
