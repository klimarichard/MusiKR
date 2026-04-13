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
class ChartCanvas extends ConsumerStatefulWidget {
  final String songId;

  const ChartCanvas({super.key, required this.songId});

  @override
  ConsumerState<ChartCanvas> createState() => _ChartCanvasState();
}

class _ChartCanvasState extends ConsumerState<ChartCanvas> {
  int _pointerCount = 0;

  @override
  Widget build(BuildContext context) {
    final editorAsync = ref.watch(editorProvider(widget.songId));
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

            final notifier = ref.read(editorProvider(widget.songId).notifier);

            return Stack(
              children: [
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) =>
                      setState(() => _pointerCount++),
                  child: SingleChildScrollView(
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
                  ),
                ),
                // DEBUG overlay — remove once tap works
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Text(
                      'body taps=$_pointerCount  rows=${rows.length}  w=${availableWidth.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
