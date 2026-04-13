import '../models/song.dart';
import '../models/app_settings.dart';

/// A single bar positioned within a layout row.
class BarLayout {
  final String barId;
  final String sectionId;

  /// Computed render width in logical pixels.
  final double width;

  const BarLayout({
    required this.barId,
    required this.sectionId,
    required this.width,
  });
}

/// A horizontal row of bars on the chart canvas.
class LayoutRow {
  final List<BarLayout> bars;
  const LayoutRow(this.bars);

  bool get isEmpty => bars.isEmpty;
}

/// Pure layout computation — no Flutter imports, fully unit-testable.
///
/// Takes a [Song] and screen metrics and returns [List<LayoutRow>] describing
/// how bars should be arranged on the canvas. The chart canvas widget consumes
/// this output to build its widget tree without doing any layout math itself.
class LayoutEngine {
  const LayoutEngine();

  /// Computes the layout for [song].
  ///
  /// [availableWidth]  — usable canvas width in logical pixels.
  /// [pixelsPerMm]     — screen density (logical pixels per millimetre).
  /// [settings]        — user settings (equalWidthBars, minBarWidthMm).
  List<LayoutRow> compute({
    required Song song,
    required double availableWidth,
    required double pixelsPerMm,
    required AppSettings settings,
  }) {
    final minBarWidth = settings.minBarWidthMm * pixelsPerMm;
    final rows = <LayoutRow>[];

    for (final section in song.sections) {
      if (section.bars.isEmpty) continue;

      if (settings.equalWidthBars) {
        // Equal-width mode: fit as many bars per row as possible at equal width,
        // respecting the minimum bar width constraint.
        final maxPerRow = (availableWidth / minBarWidth).floor().clamp(1, 8);
        final barWidth = availableWidth / maxPerRow;

        final bars = section.bars;
        for (int i = 0; i < bars.length; i += maxPerRow) {
          final rowBars = bars.sublist(i, (i + maxPerRow).clamp(0, bars.length));
          rows.add(LayoutRow(
            rowBars
                .map((b) => BarLayout(
                      barId: b.id,
                      sectionId: section.id,
                      width: barWidth,
                    ))
                .toList(),
          ));
        }
      } else {
        // Proportional mode: bars flow into rows until availableWidth is filled.
        // Each bar's width is proportional to its chord slot count.
        var rowBars = <BarLayout>[];
        var rowWidth = 0.0;

        for (final bar in section.bars) {
          final slotCount = (bar.chords.length + bar.splitSlots.length)
              .clamp(1, 4)
              .toDouble();
          final barWidth = (slotCount / 4) * availableWidth;
          final effectiveWidth = barWidth.clamp(minBarWidth, availableWidth);

          if (rowWidth + effectiveWidth > availableWidth + 0.5 && rowBars.isNotEmpty) {
            rows.add(LayoutRow(rowBars));
            rowBars = [];
            rowWidth = 0;
          }

          rowBars.add(BarLayout(
            barId: bar.id,
            sectionId: section.id,
            width: effectiveWidth,
          ));
          rowWidth += effectiveWidth;
        }

        if (rowBars.isNotEmpty) rows.add(LayoutRow(rowBars));
      }
    }

    return rows;
  }
}
