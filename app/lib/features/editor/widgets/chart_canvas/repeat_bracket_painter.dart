import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../domain/models/bar_marker.dart';

/// Paints repeat barlines, numbered ending brackets, and navigation/articulation
/// markers on top of a bar.
///
/// Phase 1 uses canvas primitives only — no SMuFL glyphs from the Leland font.
class RepeatBracketPainter extends CustomPainter {
  final List<BarMarker> markers;

  const RepeatBracketPainter(this.markers);

  @override
  void paint(Canvas canvas, Size size) {
    if (markers.isEmpty) return;

    final linePaint = Paint()
      ..color = AppColors.chartLines
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    final thickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = kBarlineThickDp
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    for (final marker in markers) {
      switch (marker) {
        case RepeatStart():
          _paintRepeatStart(canvas, size, thickPaint, dotPaint);

        case RepeatEnd():
          _paintRepeatEnd(canvas, size, thickPaint, dotPaint);

        case EndingStart(number: final n):
          _paintEndingStart(canvas, size, linePaint, n);

        case EndingEnd():
          _paintEndingEnd(canvas, size, linePaint);

        case Coda():
          _paintTextTopCenter(canvas, size, '𝄌');

        case Segno():
          _paintTextTopCenter(canvas, size, '𝄋');

        case Fine():
          _paintTextBottomRight(canvas, size, 'Fine');

        case DalCapo():
          _paintTextBottomRight(canvas, size, 'D.C.');

        case DalSegno():
          _paintTextBottomRight(canvas, size, 'D.S.');

        case DalCapoAlFine():
          _paintTextBottomRight(canvas, size, 'D.C. al Fine');

        case DalSegnoAlCoda():
          _paintTextBottomRight(canvas, size, 'D.S. al Coda');

        case Fermata():
          _paintTextTopRight(canvas, size, '𝄐');

        case Caesura():
          _paintTextTopRight(canvas, size, '//');

        case BreathMark():
          _paintTextTopRight(canvas, size, ',');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Repeat barlines
  // ---------------------------------------------------------------------------

  void _paintRepeatStart(Canvas canvas, Size size, Paint thick, Paint dot) {
    // Thick left barline
    canvas.drawLine(
      Offset(kBarlineThickDp / 2, 0),
      Offset(kBarlineThickDp / 2, size.height),
      thick,
    );
    // Two dots to the right of the thick line
    final dotX = kBarlineThickDp + 6;
    canvas.drawCircle(Offset(dotX, size.height * 0.35), kRepeatDotRadiusDp, dot);
    canvas.drawCircle(Offset(dotX, size.height * 0.65), kRepeatDotRadiusDp, dot);
  }

  void _paintRepeatEnd(Canvas canvas, Size size, Paint thick, Paint dot) {
    // Two dots to the left of the thick line
    final dotX = size.width - kBarlineThickDp - 6;
    canvas.drawCircle(Offset(dotX, size.height * 0.35), kRepeatDotRadiusDp, dot);
    canvas.drawCircle(Offset(dotX, size.height * 0.65), kRepeatDotRadiusDp, dot);
    // Thick right barline
    canvas.drawLine(
      Offset(size.width - kBarlineThickDp / 2, 0),
      Offset(size.width - kBarlineThickDp / 2, size.height),
      thick,
    );
  }

  // ---------------------------------------------------------------------------
  // Numbered ending brackets
  // ---------------------------------------------------------------------------

  void _paintEndingStart(Canvas canvas, Size size, Paint line, int number) {
    final bracketPaint = line
      ..color = Colors.black87
      ..strokeWidth = 1.5;

    // Horizontal line across the top
    canvas.drawLine(
      Offset(0, kEndingBracketHeightDp),
      Offset(size.width, kEndingBracketHeightDp),
      bracketPaint,
    );
    // Left vertical drop
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, kEndingBracketHeightDp),
      bracketPaint,
    );

    // Number label
    _paintLabel(
      canvas,
      '$number.',
      const Offset(4, 1),
      fontSize: 11,
      color: Colors.black87,
    );
  }

  void _paintEndingEnd(Canvas canvas, Size size, Paint line) {
    final bracketPaint = line
      ..color = Colors.black87
      ..strokeWidth = 1.5;

    // Right vertical drop
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, kEndingBracketHeightDp),
      bracketPaint,
    );
  }

  // ---------------------------------------------------------------------------
  // Text helpers
  // ---------------------------------------------------------------------------

  void _paintTextTopCenter(Canvas canvas, Size size, String text) {
    _paintLabel(
      canvas,
      text,
      Offset(size.width / 2 - 8, 2),
      fontSize: 14,
      color: Colors.black54,
    );
  }

  void _paintTextTopRight(Canvas canvas, Size size, String text) {
    _paintLabel(
      canvas,
      text,
      Offset(size.width - 24, 2),
      fontSize: 12,
      color: Colors.black54,
    );
  }

  void _paintTextBottomRight(Canvas canvas, Size size, String text) {
    _paintLabel(
      canvas,
      text,
      Offset(4, size.height - 16),
      fontSize: 11,
      color: Colors.black54,
    );
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    required double fontSize,
    required Color color,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color, height: 1.0),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(RepeatBracketPainter oldDelegate) =>
      oldDelegate.markers != markers;
}
