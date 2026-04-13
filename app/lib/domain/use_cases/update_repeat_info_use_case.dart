import '../models/song.dart';
import '../models/repeat_info.dart';
import '../../core/utils/result.dart';

/// Sets or clears the [RepeatInfo] on a section.
///
/// Pass [repeatInfo] = null to remove all repeat markings from the section.
class UpdateRepeatInfoUseCase {
  Result<Song> call({
    required Song song,
    required String sectionId,
    RepeatInfo? repeatInfo,
  }) {
    final sectionIndex = song.sections.indexWhere((s) => s.id == sectionId);
    if (sectionIndex == -1) return const Err('Section not found');

    final newSections = [...song.sections];
    newSections[sectionIndex] =
        song.sections[sectionIndex].copyWith(repeatInfo: repeatInfo);

    return Ok(song.copyWith(sections: newSections));
  }
}
