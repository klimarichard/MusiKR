import '../models/song.dart';

/// Persistence contract for [Song] entities.
///
/// Phase 1: implemented by [InMemorySongRepository].
/// Phase 2: replaced by [DriftSongRepository] — no other code changes needed.
abstract class SongRepository {
  /// Returns all songs, ordered by last-modified descending.
  Future<List<Song>> listSongs();

  /// Returns the song with [id], or null if not found.
  Future<Song?> getSong(String id);

  /// Inserts or replaces [song] (upsert by id).
  Future<void> saveSong(Song song);

  /// Permanently deletes the song with [id].
  /// No-op if not found.
  Future<void> deleteSong(String id);

  /// Returns songs whose title or artist contains [query] (case-insensitive).
  Future<List<Song>> searchSongs(String query);
}
