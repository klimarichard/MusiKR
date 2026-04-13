import '../models/song.dart';
import '../../core/utils/result.dart';

/// Removes the bar with [barId] from its section.
///
/// Returns [Err] if the bar is the last one in its section
/// (every section must have at least one bar).
class DeleteBarUseCase {
  Result<Song> call({
    required Song song,
    required String sectionId,
    required String barId,
  }) {
    final sectionIndex = song.sections.indexWhere((s) => s.id == sectionId);
    if (sectionIndex == -1) return const Err('Section not found');

    final section = song.sections[sectionIndex];
    if (section.bars.length <= 1) {
      return const Err('Cannot delete the last bar in a section');
    }

    final newBars = section.bars.where((b) => b.id != barId).toList();
    if (newBars.length == section.bars.length) {
      return const Err('Bar not found');
    }

    final newSections = [...song.sections];
    newSections[sectionIndex] = section.copyWith(bars: newBars);

    return Ok(song.copyWith(sections: newSections));
  }
}
