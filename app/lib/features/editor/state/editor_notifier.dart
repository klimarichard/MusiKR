import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/result.dart';
import '../../../domain/models/song.dart';
import '../../../domain/models/metadata.dart';
import '../../../domain/models/repeat_info.dart';
import '../../../domain/models/chord_symbol.dart';
import '../../../domain/value_objects/chord_input_mode.dart';
import 'editor_state.dart';

/// Manages all mutable editor state for an open song.
///
/// Uses [FamilyAsyncNotifier] so each song ID gets its own independent
/// notifier instance. The undo/redo stacks live here (not in [EditorState])
/// to keep the state slim; only the derived [canUndo]/[canRedo] flags are
/// surfaced to the UI.
class EditorNotifier extends FamilyAsyncNotifier<EditorState, String> {
  final _undoStack = <Song>[];
  final _redoStack = <Song>[];

  @override
  Future<EditorState> build(String arg) async {
    final songId = arg;
    final repo = ref.read(songRepositoryProvider);

    var song = await repo.getSong(songId);

    if (song == null) {
      // Fallback: create a blank song and persist it.
      // This should not happen in normal flow (the library creates the song
      // before navigating here), but guards against stale routes.
      final result = ref.read(createSongUseCaseProvider).call();
      if (result case Ok(:final value)) {
        await repo.saveSong(value);
        song = value;
      } else {
        throw StateError('Failed to create fallback song for id=$songId');
      }
    }

    return EditorState(song: song);
  }

  // -------------------------------------------------------------------------
  // Focus management
  // -------------------------------------------------------------------------

  /// Selects [barId] without focusing any specific slot.
  void focusBar(String barId) {
    _updateSync((s) => s.copyWith(focusedBarId: barId, focusedSlotIndex: null));
  }

  /// Focuses slot [slotIndex] (1-based) within [barId].
  void focusSlot(String barId, int slotIndex) {
    debugPrint('focusSlot barId=$barId slotIndex=$slotIndex state=${state.runtimeType}');
    _updateSync((s) => s.copyWith(focusedBarId: barId, focusedSlotIndex: slotIndex));
    debugPrint('focusSlot after update focusedBarId=${state.valueOrNull?.focusedBarId}');
  }

  /// Clears bar and slot selection.
  void clearFocus() {
    _updateSync((s) => s.copyWith(focusedBarId: null, focusedSlotIndex: null));
  }

  /// Switches the chord input mode for this session.
  void setInputMode(ChordInputMode mode) {
    _updateSync((s) => s.copyWith(inputMode: mode));
  }

  // -------------------------------------------------------------------------
  // Song mutations
  // -------------------------------------------------------------------------

  Future<void> updateChord({
    required String sectionId,
    required String barId,
    required int slotPosition,
    required ChordSymbol? chord,
  }) async {
    if (state case AsyncData(:final value)) {
      final result = ref.read(updateChordUseCaseProvider).call(
        song: value.song,
        sectionId: sectionId,
        barId: barId,
        slotPosition: slotPosition,
        chord: chord,
      );
      await _applyResult(value, result);
    }
  }

  Future<void> insertBar({
    required String sectionId,
    int? atIndex,
  }) async {
    if (state case AsyncData(:final value)) {
      final result = ref.read(insertBarUseCaseProvider).call(
        song: value.song,
        sectionId: sectionId,
        atIndex: atIndex,
      );
      await _applyResult(value, result);
    }
  }

  Future<void> deleteBar({
    required String sectionId,
    required String barId,
  }) async {
    if (state case AsyncData(:final value)) {
      final result = ref.read(deleteBarUseCaseProvider).call(
        song: value.song,
        sectionId: sectionId,
        barId: barId,
      );
      final newState = await _applyResult(value, result);
      // Clear focus if the deleted bar was selected.
      if (newState != null && value.focusedBarId == barId) {
        state = AsyncData(newState.copyWith(focusedBarId: null, focusedSlotIndex: null));
      }
    }
  }

  Future<void> insertSection({String name = '', int? atIndex}) async {
    if (state case AsyncData(:final value)) {
      final result = ref.read(insertSectionUseCaseProvider).call(
        song: value.song,
        name: name,
        atIndex: atIndex,
      );
      await _applyResult(value, result);
    }
  }

  Future<void> deleteSection(String sectionId) async {
    if (state case AsyncData(:final value)) {
      final result = ref.read(deleteSectionUseCaseProvider).call(
        song: value.song,
        sectionId: sectionId,
      );
      await _applyResult(value, result);
    }
  }

  Future<void> updateRepeatInfo(String sectionId, RepeatInfo? repeatInfo) async {
    if (state case AsyncData(:final value)) {
      final result = ref.read(updateRepeatInfoUseCaseProvider).call(
        song: value.song,
        sectionId: sectionId,
        repeatInfo: repeatInfo,
      );
      await _applyResult(value, result);
    }
  }

  Future<void> updateMetadata(Metadata metadata) async {
    if (state case AsyncData(:final value)) {
      final result = ref.read(updateMetadataUseCaseProvider).call(
        song: value.song,
        metadata: metadata,
      );
      await _applyResult(value, result);
    }
  }

  // -------------------------------------------------------------------------
  // Undo / redo
  // -------------------------------------------------------------------------

  Future<void> undo() async {
    if (_undoStack.isEmpty) return;
    if (state case AsyncData(:final value)) {
      _redoStack.add(value.song);
      final previous = _undoStack.removeLast();
      await ref.read(songRepositoryProvider).saveSong(previous);
      state = AsyncData(value.copyWith(
        song: previous,
        isDirty: true,
        canUndo: _undoStack.isNotEmpty,
        canRedo: true,
      ));
    }
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    if (state case AsyncData(:final value)) {
      _undoStack.add(value.song);
      final next = _redoStack.removeLast();
      await ref.read(songRepositoryProvider).saveSong(next);
      state = AsyncData(value.copyWith(
        song: next,
        isDirty: true,
        canUndo: true,
        canRedo: _redoStack.isNotEmpty,
      ));
    }
  }

  // -------------------------------------------------------------------------
  // Persistence
  // -------------------------------------------------------------------------

  Future<void> save() async {
    if (state case AsyncData(:final value)) {
      await ref.read(songRepositoryProvider).saveSong(value.song);
      state = AsyncData(value.copyWith(isDirty: false));
    }
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  /// Applies a [Result<Song>] from a use case.
  ///
  /// On success: pushes the previous song onto the undo stack, clears redo,
  /// persists the new song, and updates the state.
  /// On failure: briefly surfaces an [AsyncError] then restores [current].
  ///
  /// Returns the new [EditorState] on success, null on failure.
  Future<EditorState?> _applyResult(EditorState current, Result<Song> result) async {
    switch (result) {
      case Ok(:final value):
        _undoStack.add(current.song);
        _redoStack.clear();
        await ref.read(songRepositoryProvider).saveSong(value);
        final next = current.copyWith(
          song: value,
          isDirty: true,
          canUndo: true,
          canRedo: false,
        );
        state = AsyncData(next);
        return next;

      case Err(:final message):
        // Surface the error briefly so the UI can show a snackbar/toast,
        // then restore the previous state — mutations are never partially applied.
        state = AsyncError(message, StackTrace.current);
        await Future.delayed(Duration.zero);
        state = AsyncData(current);
        return null;
    }
  }

  /// Applies a synchronous state transform only when data is available.
  void _updateSync(EditorState Function(EditorState) transform) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(transform(value));
    }
  }
}
