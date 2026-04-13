import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/models/song.dart';
import '../../../domain/value_objects/chord_input_mode.dart';

part 'editor_state.freezed.dart';

/// Immutable snapshot of the editor at a point in time.
///
/// Consumed by the chart canvas and toolbar widgets to drive rendering.
/// The undo/redo stacks are internal to [EditorNotifier] and are not stored
/// here — only the derived [canUndo] / [canRedo] flags are exposed for the UI.
@freezed
class EditorState with _$EditorState {
  const factory EditorState({
    /// The song currently open in the editor.
    required Song song,

    /// The bar that currently has keyboard/interaction focus.
    /// Null when nothing is selected.
    String? focusedBarId,

    /// 1-based position of the focused chord slot within [focusedBarId].
    /// Null when the bar is selected but no specific slot is focused.
    int? focusedSlotIndex,

    /// Active chord input mode for this session.
    @Default(ChordInputMode.smartKeyboard) ChordInputMode inputMode,

    /// True when the in-memory song differs from the last saved state.
    @Default(false) bool isDirty,

    /// Whether the undo stack has entries.
    @Default(false) bool canUndo,

    /// Whether the redo stack has entries.
    @Default(false) bool canRedo,
  }) = _EditorState;
}
