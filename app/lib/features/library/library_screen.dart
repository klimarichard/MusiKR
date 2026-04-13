import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../../core/utils/result.dart';

/// Displays all saved charts and allows creating new ones.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MusiKR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: libraryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading library: $e')),
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.library_music_outlined,
                      size: 64, color: Colors.black26),
                  SizedBox(height: 16),
                  Text(
                    'No charts yet',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap + to create your first chart.',
                    style: TextStyle(color: Colors.black38),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: songs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final song = songs[i];
              final title = song.metadata.title.isEmpty
                  ? 'Untitled'
                  : song.metadata.title;
              final artist = song.metadata.artist;
              return ListTile(
                title: Text(title),
                subtitle: artist.isNotEmpty ? Text(artist) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/editor/${song.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New chart',
        onPressed: () => _createSong(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createSong(BuildContext context, WidgetRef ref) async {
    final result = ref.read(createSongUseCaseProvider).call();
    if (result case Ok(:final value)) {
      await ref.read(songRepositoryProvider).saveSong(value);
      ref.invalidate(libraryProvider);
      if (context.mounted) {
        context.go('/editor/${value.id}');
      }
    }
  }
}
