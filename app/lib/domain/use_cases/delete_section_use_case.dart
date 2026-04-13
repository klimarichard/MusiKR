import '../models/song.dart';
import '../../core/utils/result.dart';

/// Removes the section with [sectionId] from the song.
///
/// Returns [Err] if it is the last section
/// (every song must have at least one section).
class DeleteSectionUseCase {
  Result<Song> call({
    required Song song,
    required String sectionId,
  }) {
    if (song.sections.length <= 1) {
      return const Err('Cannot delete the last section in a song');
    }

    final newSections = song.sections.where((s) => s.id != sectionId).toList();
    if (newSections.length == song.sections.length) {
      return const Err('Section not found');
    }

    return Ok(song.copyWith(sections: newSections));
  }
}
