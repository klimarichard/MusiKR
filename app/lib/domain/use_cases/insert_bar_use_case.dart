import '../models/song.dart';
import '../models/bar.dart';
import '../../core/utils/uuid_generator.dart';
import '../../core/utils/result.dart';

/// Inserts a new empty [Bar] into a section at [atIndex].
///
/// If [atIndex] is null the bar is appended to the end of the section.
class InsertBarUseCase {
  Result<Song> call({
    required Song song,
    required String sectionId,
    int? atIndex,
  }) {
    final sectionIndex = song.sections.indexWhere((s) => s.id == sectionId);
    if (sectionIndex == -1) return const Err('Section not found');

    final section = song.sections[sectionIndex];
    final newBar = Bar(id: generateId());

    final newBars = [...section.bars];
    final insertAt = atIndex ?? newBars.length;

    if (insertAt < 0 || insertAt > newBars.length) {
      return const Err('Insert index out of range');
    }
    newBars.insert(insertAt, newBar);

    final newSections = [...song.sections];
    newSections[sectionIndex] = section.copyWith(bars: newBars);

    return Ok(song.copyWith(sections: newSections));
  }
}
