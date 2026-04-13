import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/chord_symbol.dart';
import '../../../domain/value_objects/accidental.dart';
import '../../../domain/value_objects/chord_extension.dart';
import '../../../domain/value_objects/chord_quality.dart';
import '../../../domain/value_objects/note_name.dart';

/// Manages the chord currently being assembled in the smart keyboard.
///
/// State is [ChordSymbol?]:
/// - null  → no chord is being built (nothing committed yet for this slot)
/// - non-null → the partial/complete chord as the user builds it
///
/// Auto-disposed when the chord input panel leaves the widget tree, which
/// resets the state for the next slot.
class ChordInputNotifier extends StateNotifier<ChordSymbol?> {
  ChordInputNotifier() : super(null);

  /// Sets the root note, resetting quality to major and clearing extensions.
  void setRoot(NoteName note, Accidental accidental) {
    state = ChordSymbol(
      root: note,
      accidental: accidental == Accidental.natural ? Accidental.natural : accidental,
      quality: ChordQuality.major,
    );
  }

  /// Updates the quality of the chord being built.
  void setQuality(ChordQuality quality) {
    if (state == null) return;
    state = state!.copyWith(quality: quality);
  }

  /// Adds or removes [ext] from the extensions list (toggle).
  void toggleExtension(ChordExtension ext) {
    if (state == null) return;
    final current = List<ChordExtension>.from(state!.extensions);
    final idx = current.indexWhere(
      (e) => e.degree == ext.degree && e.alteration == ext.alteration && e.isAdded == ext.isAdded,
    );
    if (idx == -1) {
      current.add(ext);
    } else {
      current.removeAt(idx);
    }
    state = state!.copyWith(extensions: current);
  }

  /// Sets the slash-chord bass note. Pass null to clear.
  void setBass(NoteName? note, Accidental? accidental) {
    if (state == null) return;
    state = state!.copyWith(
      bass: note,
      bassAccidental: note == null ? null : accidental,
    );
  }

  /// Resets to the empty state (no chord being built).
  void reset() => state = null;
}

/// Auto-disposed — resets when the chord input panel leaves the tree.
final chordInputProvider =
    StateNotifierProvider.autoDispose<ChordInputNotifier, ChordSymbol?>(
  (_) => ChordInputNotifier(),
);
