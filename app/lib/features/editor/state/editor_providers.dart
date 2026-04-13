import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'editor_notifier.dart';
import 'editor_state.dart';

/// Provides an [EditorNotifier] scoped to a specific song ID.
///
/// Usage:
/// ```dart
/// final editorAsync = ref.watch(editorProvider(songId));
/// final notifier    = ref.read(editorProvider(songId).notifier);
/// ```
///
/// Each unique [songId] gets its own independent notifier and undo/redo stack.
/// The notifier is disposed automatically when no widget watches it.
final editorProvider =
    AsyncNotifierProvider.family<EditorNotifier, EditorState, String>(
  EditorNotifier.new,
);
