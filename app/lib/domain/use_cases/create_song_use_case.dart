import '../models/song.dart';
import '../models/section.dart';
import '../models/bar.dart';
import '../models/metadata.dart';
import '../../core/utils/uuid_generator.dart';
import '../../core/utils/result.dart';

/// Creates a new [Song] with default metadata, one empty section, and four empty bars.
class CreateSongUseCase {
  Result<Song> call({String title = '', String artist = ''}) {
    final bar1 = Bar(id: generateId());
    final bar2 = Bar(id: generateId());
    final bar3 = Bar(id: generateId());
    final bar4 = Bar(id: generateId());

    final section = Section(
      id: generateId(),
      name: 'A',
      bars: [bar1, bar2, bar3, bar4],
    );

    final song = Song(
      id: generateId(),
      metadata: Metadata.defaults().copyWith(
        title: title,
        artist: artist,
      ),
      sections: [section],
    );

    return Ok(song);
  }
}
