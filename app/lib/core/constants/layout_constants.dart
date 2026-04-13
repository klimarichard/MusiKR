// Layout constants shared across the chart canvas and PDF export.
// All values are in logical pixels (dp) unless the name ends in `Mm`.

/// Minimum bar width in millimetres — matches the AppSettings default.
const double kMinBarWidthMm = 18.0;

/// Fixed height of a single bar row on the chart canvas.
const double kBarHeightDp = 80.0;

/// Width of a normal (thin) barline.
const double kBarlineThinDp = 1.5;

/// Width of a thick barline (used in repeat start/end).
const double kBarlineThickDp = 4.0;

/// Radius of the two dots in a repeat barline.
const double kRepeatDotRadiusDp = 3.0;

/// Vertical height of a numbered ending bracket line above the bar.
const double kEndingBracketHeightDp = 12.0;

/// Height of the section header band above each section's bars.
const double kSectionHeaderHeightDp = 32.0;

/// Horizontal and vertical padding around the entire chart canvas.
const double kCanvasPaddingDp = 16.0;
