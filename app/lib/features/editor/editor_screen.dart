import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import 'chord_input/chord_input_panel.dart';
import 'state/editor_providers.dart';
import 'widgets/chart_canvas/chart_canvas.dart';
import 'widgets/editor_toolbar.dart';

/// Top-level editor screen for a single song.
///
/// Layout:
/// - AppBar with title + [EditorToolbar] actions
/// - Body: [ChartCanvas] (scrollable chart)
/// - BottomSheet: [ChordInputPanel] (visible when a bar/slot is focused)
class EditorScreen extends ConsumerWidget {
  final String songId;

  const EditorScreen({super.key, required this.songId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorAsync = ref.watch(editorProvider(songId));

    return editorAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Failed to load song: $e')),
      ),
      data: (state) {
        final title = state.song.metadata.title.isEmpty
            ? 'Untitled'
            : state.song.metadata.title;

        return Scaffold(
          backgroundColor: AppColors.chartPaper,
          appBar: AppBar(
            title: Text(title),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurface,
            actions: [EditorToolbar(songId: songId)],
          ),
          body: Column(
            children: [
              Expanded(child: ChartCanvas(songId: songId)),
              if (state.focusedBarId != null)
                ChordInputPanel(songId: songId),
            ],
          ),
        );
      },
    );
  }
}
