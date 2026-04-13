import 'package:freezed_annotation/freezed_annotation.dart';
import 'accidental.dart';

part 'chord_extension.freezed.dart';

/// A single extension or alteration added to a chord (e.g. ♭9, ♯11, add9).
@freezed
class ChordExtension with _$ChordExtension {
  const factory ChordExtension({
    /// Scale degree: 2, 4, 5, 6, 7, 9, 11, 13
    required int degree,

    /// null = natural (no accidental prefix)
    Accidental? alteration,

    /// True for "add" extensions (add9, add11) — not part of a full extension stack
    @Default(false) bool isAdded,
  }) = _ChordExtension;
}
