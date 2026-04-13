import '../models/song.dart';
import '../models/chord_slot.dart';
import '../models/chord_symbol.dart';
import '../../core/utils/result.dart';

/// Writes [chord] into the given slot of a bar, returning a new [Song].
///
/// If [chord] is null the slot is cleared.
/// If the slot at [slotPosition] does not exist it is created.
class UpdateChordUseCase {
  Result<Song> call({
    required Song song,
    required String sectionId,
    required String barId,
    required int slotPosition,
    ChordSymbol? chord,
  }) {
    final sectionIndex = song.sections.indexWhere((s) => s.id == sectionId);
    if (sectionIndex == -1) return const Err('Section not found');

    final section = song.sections[sectionIndex];
    final barIndex = section.bars.indexWhere((b) => b.id == barId);
    if (barIndex == -1) return const Err('Bar not found');

    final bar = section.bars[barIndex];
    final slotIndex = bar.chords.indexWhere((s) => s.position == slotPosition);

    final List<ChordSlot> newChords;
    if (slotIndex == -1) {
      // Slot does not exist — create it
      newChords = [...bar.chords, ChordSlot(position: slotPosition, chord: chord)];
    } else {
      // Update existing slot
      newChords = [...bar.chords];
      newChords[slotIndex] = bar.chords[slotIndex].copyWith(chord: chord);
    }

    final newBar = bar.copyWith(chords: newChords);
    final newBars = [...section.bars];
    newBars[barIndex] = newBar;

    final newSection = section.copyWith(bars: newBars);
    final newSections = [...song.sections];
    newSections[sectionIndex] = newSection;

    return Ok(song.copyWith(sections: newSections));
  }
}
