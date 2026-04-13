import '../models/song.dart';
import '../models/metadata.dart';
import '../../core/utils/result.dart';

/// Replaces the song's [Metadata] with [metadata].
class UpdateMetadataUseCase {
  Result<Song> call({
    required Song song,
    required Metadata metadata,
  }) {
    return Ok(song.copyWith(metadata: metadata));
  }
}
