import '../../domain/models/song.dart';
import '../../domain/repositories/song_repository.dart';

/// In-memory implementation of [SongRepository] for Phase 1.
///
/// Songs are stored in a [Map] keyed by id; all changes are lost on restart.
/// Replace with [DriftSongRepository] in the Phase 2 data sub-phase by
/// flipping the provider in core/di/providers.dart.
class InMemorySongRepository implements SongRepository {
  final Map<String, Song> _store = {};

  @override
  Future<List<Song>> listSongs() async =>
      _store.values.toList().reversed.toList();

  @override
  Future<Song?> getSong(String id) async => _store[id];

  @override
  Future<void> saveSong(Song song) async {
    _store[song.id] = song;
  }

  @override
  Future<void> deleteSong(String id) async {
    _store.remove(id);
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    final q = query.toLowerCase();
    return _store.values.where((s) {
      return s.metadata.title.toLowerCase().contains(q) ||
          s.metadata.artist.toLowerCase().contains(q);
    }).toList();
  }
}
