import '../models/song.dart';
import '../models/section.dart';
import '../models/bar.dart';
import '../../core/utils/uuid_generator.dart';
import '../../core/utils/result.dart';

/// Inserts a new [Section] with four empty bars at [atIndex].
///
/// If [atIndex] is null the section is appended to the end of the song.
class InsertSectionUseCase {
  Result<Song> call({
    required Song song,
    String name = '',
    int? atIndex,
  }) {
    final newSection = Section(
      id: generateId(),
      name: name,
      bars: [
        Bar(id: generateId()),
        Bar(id: generateId()),
        Bar(id: generateId()),
        Bar(id: generateId()),
      ],
    );

    final newSections = [...song.sections];
    final insertAt = atIndex ?? newSections.length;

    if (insertAt < 0 || insertAt > newSections.length) {
      return const Err('Insert index out of range');
    }
    newSections.insert(insertAt, newSection);

    return Ok(song.copyWith(sections: newSections));
  }
}
