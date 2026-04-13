import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../domain/models/app_settings.dart';
import '../../../../domain/models/song.dart';
import '../../../../domain/services/layout_engine.dart';
import '../../state/editor_providers.dart';
import 'section_view.dart';

/// Scrollable chart canvas that lays out [SectionView]s using [LayoutEngine].
///
/// Watches [editorProvider] for live song and focus state changes.
/// Uses [LayoutBuilder] so bar widths reflow when the window is resized.
class ChartCanvas extends ConsumerWidget {
  final String songId;

  const ChartCanvas({super.key, required this.songId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorAsync = ref.watch(editorProvider(songId));
    final settingsAsync = ref.watch(appSettingsProvider);

    return editorAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (editorState) {
        final settings =
            settingsAsync.valueOrNull ?? AppSettings.defaults();

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth =
                constraints.maxWidth - kCanvasPaddingDp * 2;

            // Approximate pixels-per-mm from device pixel ratio.
            // 3.78 px/mm ≈ 96 dpi (logical pixels are device-independent).
            final pixelsPerMm =
                MediaQuery.of(context).devicePixelRatio / 3.78;

            final engine = ref.read(layoutEngineProvider);
            final rows = engine.compute(
              song: editorState.song,
              availableWidth: availableWidth,
              pixelsPerMm: pixelsPerMm,
              settings: settings,
            );

            final rowsBySection =
                _groupRowsBySection(editorState.song, rows);

            final notifier = ref.read(editorProvider(songId).notifier);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(kCanvasPaddingDp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: editorState.song.sections.map((section) {
                  return SectionView(
                    section: section,
                    rows: rowsBySection[section.id] ?? [],
                    focusedBarId: editorState.focusedBarId,
                    focusedSlotIndex: editorState.focusedSlotIndex,
                    onSlotTap: (barId, slotPos) =>
                        notifier.focusSlot(barId, slotPos),
                    onSectionTap: () {},
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  /// Groups [LayoutRow]s by section, using the [BarLayout.sectionId] of the
  /// first bar in each row (all bars in a row belong to the same section).
  Map<String, List<LayoutRow>> _groupRowsBySection(
    Song song,
    List<LayoutRow> rows,
  ) {
    final result = <String, List<LayoutRow>>{};
    for (final row in rows) {
      if (row.isEmpty) continue;
      final sectionId = row.bars.first.sectionId;
      result.putIfAbsent(sectionId, () => []).add(row);
    }
    return result;
  }
}
