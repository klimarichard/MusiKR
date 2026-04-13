import '../models/song.dart';
import '../models/bar_marker.dart';

/// Severity of a repeat-structure issue.
enum ValidationSeverity { warning, error }

/// A single structural issue found by [RepeatValidator].
class RepeatIssue {
  final ValidationSeverity severity;
  final String message;

  /// Identifies the bar that triggered the issue, if applicable.
  final String? barId;
  final String? sectionId;

  const RepeatIssue({
    required this.severity,
    required this.message,
    this.barId,
    this.sectionId,
  });

  bool get isError => severity == ValidationSeverity.error;

  @override
  String toString() => '[${severity.name.toUpperCase()}] $message'
      '${barId != null ? " (bar $barId)" : ""}';
}

/// Validates the repeat and navigation marker structure of a [Song].
///
/// Returns a list of [RepeatIssue]s. An empty list means the song is valid.
/// This is a pure function — no side effects, no Flutter imports.
///
/// Rules enforced:
/// - Every [EndingStart] must be followed by an [EndingEnd] in the same section.
/// - Numbered endings must be sequential (1st, then 2nd, then 3rd…).
/// - [DalSegno] / [DalSegnoAlCoda] require at least one [Segno] marker in the song.
/// - [DalSegnoAlCoda] requires at least one [Coda] marker in the song.
/// - [Fine] / [DalCapoAlFine] must co-exist: if one is present, the other must be too.
/// - Duplicate landmark markers ([Segno], [Coda], [Fine]) are flagged as warnings.
/// - [EndingStart] without a preceding [RepeatStart] (anywhere before it in the song)
///   is flagged as a warning.
class RepeatValidator {
  const RepeatValidator();

  List<RepeatIssue> validate(Song song) {
    final issues = <RepeatIssue>[];

    // Collect global marker counts for cross-reference checks.
    int segnoCount = 0;
    int codaCount = 0;
    int fineCount = 0;
    bool hasdalSegno = false;
    bool hasdalSegnoAlCoda = false;
    bool hasdalCapoAlFine = false;

    // First pass: count global navigation markers.
    for (final section in song.sections) {
      for (final bar in section.bars) {
        for (final marker in bar.barMarkers) {
          switch (marker) {
            case Segno():
              segnoCount++;
            case Coda():
              codaCount++;
            case Fine():
              fineCount++;
            case DalSegno():
              hasdalSegno = true;
            case DalSegnoAlCoda():
              hasdalSegnoAlCoda = true;
            case DalCapoAlFine():
              hasdalCapoAlFine = true;
            default:
              break;
          }
        }
      }
    }

    // Global cross-reference issues.
    if (segnoCount > 1) {
      issues.add(const RepeatIssue(
        severity: ValidationSeverity.warning,
        message: 'Multiple Segno (𝄋) markers found — playback may be ambiguous.',
      ));
    }
    if (codaCount > 1) {
      issues.add(const RepeatIssue(
        severity: ValidationSeverity.warning,
        message: 'Multiple Coda (𝄌) markers found — playback may be ambiguous.',
      ));
    }
    if (fineCount > 1) {
      issues.add(const RepeatIssue(
        severity: ValidationSeverity.warning,
        message: 'Multiple Fine markers found — playback may be ambiguous.',
      ));
    }
    if ((hasdalSegno || hasdalSegnoAlCoda) && segnoCount == 0) {
      issues.add(const RepeatIssue(
        severity: ValidationSeverity.error,
        message: 'D.S. marker present but no Segno (𝄋) found in the chart.',
      ));
    }
    if (hasdalSegnoAlCoda && codaCount == 0) {
      issues.add(const RepeatIssue(
        severity: ValidationSeverity.error,
        message: 'D.S. al Coda present but no Coda (𝄌) found in the chart.',
      ));
    }
    if (hasdalCapoAlFine && fineCount == 0) {
      issues.add(const RepeatIssue(
        severity: ValidationSeverity.error,
        message: 'D.C. al Fine present but no Fine marker found in the chart.',
      ));
    }
    if (fineCount > 0 && !hasdalCapoAlFine && !hasdalSegno && !hasdalSegnoAlCoda) {
      issues.add(const RepeatIssue(
        severity: ValidationSeverity.warning,
        message: 'Fine marker present but no D.C. al Fine or D.S. referencing it.',
      ));
    }

    // Second pass: per-section structural checks.
    bool repeatOpenSeen = false; // tracks whether a |: has been seen anywhere before

    for (final section in song.sections) {
      bool sectionRepeatOpen = false;
      bool inEnding = false;
      int lastEndingNumber = 0;

      for (final bar in section.bars) {
        for (final marker in bar.barMarkers) {
          switch (marker) {
            case RepeatStart():
              sectionRepeatOpen = true;
              repeatOpenSeen = true;

            case RepeatEnd():
              if (!repeatOpenSeen) {
                issues.add(RepeatIssue(
                  severity: ValidationSeverity.warning,
                  message: 'Repeat barline :| without a preceding |: '
                      '(implied repeat from the top).',
                  barId: bar.id,
                  sectionId: section.id,
                ));
              }
              sectionRepeatOpen = false;

            case EndingStart(number: final n):
              if (!repeatOpenSeen) {
                issues.add(RepeatIssue(
                  severity: ValidationSeverity.warning,
                  message: 'Numbered ending ($n) without any preceding repeat barline.',
                  barId: bar.id,
                  sectionId: section.id,
                ));
              }
              if (inEnding) {
                issues.add(RepeatIssue(
                  severity: ValidationSeverity.error,
                  message: 'Nested ending start ($n) — previous ending was not closed.',
                  barId: bar.id,
                  sectionId: section.id,
                ));
              }
              if (n != lastEndingNumber + 1) {
                issues.add(RepeatIssue(
                  severity: ValidationSeverity.warning,
                  message: 'Ending number out of sequence: expected '
                      '${lastEndingNumber + 1}, found $n.',
                  barId: bar.id,
                  sectionId: section.id,
                ));
              }
              inEnding = true;
              lastEndingNumber = n;

            case EndingEnd():
              if (!inEnding) {
                issues.add(RepeatIssue(
                  severity: ValidationSeverity.error,
                  message: 'Ending close marker without a matching ending start.',
                  barId: bar.id,
                  sectionId: section.id,
                ));
              }
              inEnding = false;

            default:
              break;
          }
        }
      }

      // Unclosed ending bracket at section boundary.
      if (inEnding) {
        issues.add(RepeatIssue(
          severity: ValidationSeverity.error,
          message: "Ending bracket was not closed before section '${section.name}' ended.",
          sectionId: section.id,
        ));
      }

      // Unclosed repeat at section boundary (warning — some styles span sections).
      if (sectionRepeatOpen) {
        issues.add(RepeatIssue(
          severity: ValidationSeverity.warning,
          message: "Repeat opened in section '${section.name}' but not closed within it.",
          sectionId: section.id,
        ));
      }
    }

    return issues;
  }
}
