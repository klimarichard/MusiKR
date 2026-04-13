import '../models/chord_symbol.dart';
import '../value_objects/note_name.dart';
import '../value_objects/accidental.dart';
import '../value_objects/chord_quality.dart';
import '../value_objects/chord_extension.dart';

class _NoteResult {
  final NoteName note;
  final Accidental accidental;
  final int consumed;
  const _NoteResult(this.note, this.accidental, this.consumed);
}

class _QualityResult {
  final ChordQuality quality;
  final int consumed;
  const _QualityResult(this.quality, this.consumed);
}

/// Parses a chord string into a [ChordSymbol].
///
/// Contract:
/// - Never throws.
/// - Never returns null.
/// - Falls back to [ChordSymbol.raw] when input cannot be parsed.
/// - Supports: roots A–G, accidentals (b/♭/#/♯/bb/##), all [ChordQuality]
///   variants, extensions (b9 #9 11 #11 13 add9 …), slash-chord bass notes.
class ChordParser {
  const ChordParser();

  ChordSymbol parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return ChordSymbol.raw(input);
    try {
      return _doParse(trimmed);
    } catch (_) {
      return ChordSymbol.raw(input);
    }
  }

  ChordSymbol _doParse(String input) {
    String main = input;
    NoteName? bass;
    Accidental? bassAccidental;

    // 1. Split off slash-chord bass note (e.g. "G7/B", "Cmaj7/E")
    final slashIdx = input.lastIndexOf('/');
    if (slashIdx > 0) {
      final bassStr = input.substring(slashIdx + 1).trim();
      final bassResult = _parseNote(bassStr);
      if (bassResult != null && bassResult.consumed == bassStr.length) {
        bass = bassResult.note;
        bassAccidental = bassResult.accidental == Accidental.natural
            ? null
            : bassResult.accidental;
        main = input.substring(0, slashIdx).trim();
      }
    }

    // 2. Parse root note
    final rootResult = _parseNote(main);
    if (rootResult == null) return ChordSymbol.raw(input);

    final root = rootResult.note;
    final rootAccidental = rootResult.accidental;
    String remaining = main.substring(rootResult.consumed);

    // 3. Parse quality
    final qualityResult = _parseQuality(remaining);
    remaining = remaining.substring(qualityResult.consumed);

    // 4. Parse extensions from what remains
    final extensions = _parseExtensions(remaining);

    return ChordSymbol(
      root: root,
      accidental: rootAccidental,
      quality: qualityResult.quality,
      extensions: extensions,
      bass: bass,
      bassAccidental: bassAccidental,
    );
  }

  // ---------------------------------------------------------------------------
  // Root note
  // ---------------------------------------------------------------------------

  _NoteResult? _parseNote(String s) {
    if (s.isEmpty) return null;

    final noteChar = s[0].toUpperCase();
    final NoteName? note = switch (noteChar) {
      'C' => NoteName.c,
      'D' => NoteName.d,
      'E' => NoteName.e,
      'F' => NoteName.f,
      'G' => NoteName.g,
      'A' => NoteName.a,
      'B' => NoteName.b,
      _ => null,
    };
    if (note == null) return null;

    const pos = 1;
    final rest = s.substring(1);

    // Double accidentals — match before single
    if (rest.startsWith('bb') || rest.startsWith('\u266d\u266d') || rest.startsWith('\u1D12B')) {
      final len = rest.startsWith('\u1D12B') ? 1 : 2;
      return _NoteResult(note, Accidental.doubleFlat, pos + len);
    }
    if (rest.startsWith('##') || rest.startsWith('\u266f\u266f') || rest.startsWith('\u1D12A')) {
      final len = rest.startsWith('\u1D12A') ? 1 : 2;
      return _NoteResult(note, Accidental.doubleSharp, pos + len);
    }
    // 'b' is flat only when not followed by a letter or digit that would make
    // it part of a quality token (e.g. "Bb" = B-flat, but "Bm" = B-minor)
    if (rest.startsWith('b') &&
        (rest.length == 1 || !RegExp(r'[0-9a-z]').hasMatch(rest[1]))) {
      return _NoteResult(note, Accidental.flat, pos + 1);
    }
    if (rest.startsWith('\u266d')) {
      return _NoteResult(note, Accidental.flat, pos + 1);
    }
    if (rest.startsWith('#') || rest.startsWith('\u266f')) {
      return _NoteResult(note, Accidental.sharp, pos + 1);
    }

    return _NoteResult(note, Accidental.natural, pos);
  }

  // ---------------------------------------------------------------------------
  // Quality — longest match first to prevent partial hits
  // ---------------------------------------------------------------------------

  static const _qualityPatterns = <(String, ChordQuality)>[
    // Minor-major 7
    ('minmaj7',  ChordQuality.minorMajor7),
    ('minMaj7',  ChordQuality.minorMajor7),
    ('mMaj7',    ChordQuality.minorMajor7),
    ('m(maj7)',  ChordQuality.minorMajor7),
    ('m(M7)',    ChordQuality.minorMajor7),
    ('-maj7',    ChordQuality.minorMajor7),
    ('-M7',      ChordQuality.minorMajor7),
    // Half-diminished
    ('m7b5',     ChordQuality.halfDiminished),
    ('min7b5',   ChordQuality.halfDiminished),
    ('\u00f87',  ChordQuality.halfDiminished), // ø7
    ('\u00f8',   ChordQuality.halfDiminished), // ø
    // Diminished 7
    ('dim7',     ChordQuality.diminished7),
    ('\u00b07',  ChordQuality.diminished7), // °7
    ('o7',       ChordQuality.diminished7),
    // Augmented 7
    ('aug7',     ChordQuality.augmented7),
    ('+7',       ChordQuality.augmented7),
    // Major 7
    ('maj7',     ChordQuality.major7),
    ('Maj7',     ChordQuality.major7),
    ('MA7',      ChordQuality.major7),
    ('M7',       ChordQuality.major7),
    ('\u03947',  ChordQuality.major7), // Δ7
    ('^7',       ChordQuality.major7),
    // Minor 7
    ('min7',     ChordQuality.minor7),
    ('m7',       ChordQuality.minor7),
    ('-7',       ChordQuality.minor7),
    // Dominant 7
    ('dom7',     ChordQuality.dominant7),
    ('7',        ChordQuality.dominant7),
    // Major (after maj7)
    ('maj',      ChordQuality.major),
    ('Maj',      ChordQuality.major),
    ('MA',       ChordQuality.major),
    ('\u0394',   ChordQuality.major), // Δ
    ('^',        ChordQuality.major),
    // Minor (after minor7 / minmaj7)
    ('min',      ChordQuality.minor),
    ('m',        ChordQuality.minor),
    ('-',        ChordQuality.minor),
    // Diminished (after dim7)
    ('dim',      ChordQuality.diminished),
    ('\u00b0',   ChordQuality.diminished), // °
    ('o',        ChordQuality.diminished),
    // Augmented (after aug7)
    ('aug',      ChordQuality.augmented),
    ('+',        ChordQuality.augmented),
    // Sus
    ('sus2',     ChordQuality.sus2),
    ('sus4',     ChordQuality.sus4),
    ('sus',      ChordQuality.sus4),
    // Power
    ('5',        ChordQuality.power),
  ];

  _QualityResult _parseQuality(String s) {
    for (final (pattern, quality) in _qualityPatterns) {
      if (s.startsWith(pattern)) {
        return _QualityResult(quality, pattern.length);
      }
    }
    // No quality token → implicit major
    return const _QualityResult(ChordQuality.major, 0);
  }

  // ---------------------------------------------------------------------------
  // Extensions
  // ---------------------------------------------------------------------------

  static final _extensionPatterns = <(RegExp, int, Accidental?, bool)>[
    // add extensions (isAdded = true)
    (RegExp(r'^add2'),           2,  null,             true),
    (RegExp(r'^add4'),           4,  null,             true),
    (RegExp(r'^add9'),           9,  null,             true),
    (RegExp(r'^add11'),         11,  null,             true),
    (RegExp(r'^add13'),         13,  null,             true),
    // altered extensions — match b/♭ and #/♯ variants
    (RegExp(r'^[b\u266d]5'),     5,  Accidental.flat,  false),
    (RegExp(r'^[#\u266f]5'),     5,  Accidental.sharp, false),
    (RegExp(r'^[b\u266d]9'),     9,  Accidental.flat,  false),
    (RegExp(r'^[#\u266f]9'),     9,  Accidental.sharp, false),
    (RegExp(r'^[b\u266d]11'),   11,  Accidental.flat,  false),
    (RegExp(r'^[#\u266f]11'),   11,  Accidental.sharp, false),
    (RegExp(r'^[b\u266d]13'),   13,  Accidental.flat,  false),
    (RegExp(r'^[#\u266f]13'),   13,  Accidental.sharp, false),
    // natural extensions — longer numbers first
    (RegExp(r'^13'),            13,  null,             false),
    (RegExp(r'^11'),            11,  null,             false),
    (RegExp(r'^9'),              9,  null,             false),
    (RegExp(r'^6'),              6,  null,             false),
  ];

  List<ChordExtension> _parseExtensions(String s) {
    final extensions = <ChordExtension>[];
    // Strip parentheses and spaces — common in "Cmaj7(#11)" or "G7 (b9)"
    String remaining = s.replaceAll(RegExp(r'[\(\)\s]'), '');

    while (remaining.isNotEmpty) {
      bool matched = false;
      for (final (pattern, degree, alteration, isAdded) in _extensionPatterns) {
        final match = pattern.firstMatch(remaining);
        if (match != null) {
          extensions.add(ChordExtension(
            degree: degree,
            alteration: alteration,
            isAdded: isAdded,
          ));
          remaining = remaining.substring(match.end);
          matched = true;
          break;
        }
      }
      if (!matched) break; // unknown suffix — stop cleanly
    }

    return extensions;
  }
}
