# MusiKR — Claude Guidelines

## Git Workflow

- **Always create a new branch before making any changes.** Never work directly on `master`.
- Branch naming: `feature/short-description`, `fix/short-description`, `chore/short-description`
- You may commit and push to the feature branch freely.
- **Only the user decides when to merge.** Never merge branches yourself.
- Use clear, descriptive commit messages explaining *why*, not just *what*.

## Project Context

### What this app is
MusiKR is a cross-platform symbolic music chart editor for professional and semi-professional musicians. It enables creation, storage, editing, and sharing of lead-sheet-style musical charts — far beyond tools like iReal Pro.

The full specification lives in `Muzihala_PRD_v1.docx` (excluded from git). It was read in full at project start. Note: the PRD used the working title "Muzihala" — the product is called **MusiKR** throughout the codebase.

### Target Platforms (v1)
| Platform | Notes |
|---|---|
| iPadOS | Primary authoring device — full Apple Pencil support |
| iOS (iPhone) | Reading and minor edits |
| Android (tablet + phone) | Full feature parity with iPad/iPhone |
| macOS | Desktop authoring with mouse/trackpad |
| Windows | Desktop authoring with mouse/trackpad |

### Technology Stack
| Layer | Recommendation |
|---|---|
| Cross-platform framework | Flutter (Dart) — single codebase, native canvas, excellent stylus support |
| Notation rendering | Custom Flutter canvas painter (SMuFL-compliant) |
| Music font | Leland (MuseScore, free, SMuFL) — `Leland.otf` + `LelandText.otf` in `app/assets/fonts/` |
| Local database | SQLite via drift package (Flutter) |
| Cloud sync | Supabase or Firebase (v2) |
| PDF export | Flutter's built-in pdf/printing package |
| OMR engine | Custom ML model or third-party (e.g. Audiveris adapted) |

### Core Architecture — The Three-Layer Model
Every chart is rendered as three composited layers sharing a single coordinate space:

| Layer | Description |
|---|---|
| Layer 1 — Chord Chart | Structured, parseable chord and section data. Transposable, searchable, exportable. |
| Layer 2 — Staff Snippets | Embedded mini-staves per bar. Contain rhythmic figures and melody hints. Always exported. |
| Layer 3 — Ink Annotations | Freehand vector strokes from stylus or mouse. Optional in export. Preserved even after transposition. |

### Data Model (top-level)
```
Song
├── id                  UUID
├── Metadata
│   ├── title, artist, composer, catalogRef
│   ├── tempo (BPM), feel (Enum), timeSignature, keySignature
│   └── tags            String[]
├── Sections[]
│   ├── id, name, repeatInfo
│   └── Bars[]
│       ├── chords      ChordSlot[]      // 1–4 chords per bar
│       ├── isSplitBar  Boolean
│       ├── splitSlots  ChordSlot[]?
│       ├── barMarkers  BarMarker[]
│       ├── staffSnippet StaffSnippet?
│       └── inkLayer    InkLayer?
└── globalInkLayer      InkLayer
```

### Key Design Rules
- **Every chord must be writable.** The app must never reject a valid musical symbol. When the parser cannot interpret a symbol, the User Chord Designer provides an escape hatch.
- Chord parser is maximally permissive — normalises all input to canonical `ChordSymbol`.
- Ink annotations are **never** modified by the transposition engine — warn the user instead.
- Staff snippet OMR confidence threshold: 0.75 (symbols below this flagged in amber). Configurable in dev settings.
- Bar-scoped ink moves and reflows with its bar. Global ink is free-floating.
- Equal-width bars mode is ON by default. Minimum bar width: 18mm.
- Deleting a folder/setlist NEVER deletes charts from the library.

### Chord Input Modes
| Mode | Description |
|---|---|
| HANDWRITE (default) | Draw chord symbol with stylus/finger; OMR parses to ChordSymbol |
| SMART KEYBOARD | Root buttons + quality selector + extension toggles |
| TEXT | Plain text with smart parser; live preview |

### Staff Snippet States
`DRAFT` → (user taps Commit) → `PRE-COMMIT CONFIDENCE GATE` → (user confirms) → `COMMITTED` → (user taps snippet) → `EDITING` (dual-pane: original ink left, structured notation right)

### Repeat & Navigation System (v1)
Simple repeats, numbered endings (1st/2nd/3rd), split bar endings, D.C. al Fine, D.S. al Coda, D.S. al Fine, Coda/Segno/Fine markers, play count, last-time-only, stop/accent/fermata/caesura/breath markers.

### Build Phases
| Phase | Scope |
|---|---|
| 1 | Core Chart Editor — data model, chord input (smart keyboard + text), section/bar structure, repeat system, page layout, equal-width bars, basic typography |
| 2 | PDF Export — clean and annotated variants, metadata block, A4 layout |
| 3 | Ink Annotation Layer — stylus/touch input, stroke model, bar/section/global scoping, undo/redo |
| 4 | Staff Snippet System — snippet canvas, OMR, confidence gate, dual-pane editor |
| 5 | Handwrite Chord Input — chord OMR, User Chord Designer, alias library |
| 6 | Library & Organisation — folders, setlists, search/filter, performance mode |
| 7 | Cloud Sync & Sharing — account system, cross-device sync, selective share links |
| 8 | Community & Licensing — public library, licensing layer, community chords |

### Development Status

**Active branch:** `feature/phase1-bootstrap`

| Area | Status |
|---|---|
| Flutter project setup | Done — `app/` subdirectory, Flutter 3.41.6, targets Android/iOS/Windows/macOS |
| Folder architecture | Done — `domain/`, `data/`, `features/`, `core/`, `app/` layers |
| Dependencies | Done — Riverpod 2.x, go_router, drift (in-memory), freezed, uuid, collection, mocktail |
| Domain models | Done — all `@freezed`: `Song`, `Section`, `Bar`, `ChordSlot`, `ChordSymbol`, `BarMarker` (sealed), `Metadata`, `RepeatInfo`, `TimeSignature`, `KeySignature`, `AppSettings`, all value objects |
| Repository layer | Done — `SongRepository` + `SettingsRepository` interfaces; `InMemory*` implementations for Phase 1 |
| Use cases | Done — `CreateSong`, `UpdateChord`, `InsertBar`, `DeleteBar`, `InsertSection`, `DeleteSection`, `UpdateRepeatInfo`, `UpdateMetadata` |
| DI providers | Done — all Riverpod providers wired in `core/di/providers.dart` |
| ChordParser service | TODO |
| LayoutEngine service | TODO |
| Editor UI | TODO — `EditorState`, `EditorNotifier`, chart canvas, chord input panel |
| Library UI | Scaffold only |
| Settings UI | Scaffold only |

### Development Setup Notes
- Flutter managed via **Puro** at `C:\puro` (not default `~/.puro` — username has spaces)
- `PURO_ROOT=C:\puro` set as system env var
- `C:\puro\bin` on PATH with `flutter.bat` and `dart.bat` shims
- Android SDK at `C:\Android\sdk` (moved from default to avoid spaces-in-path NDK issue)
- After cloning, run `flutter pub get` then `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate `.freezed.dart` files (excluded from git)

### Deferred to v2+
US Letter, public library, licensing layer, polychords, voicing hints, Roman numeral / Nashville notation, arbitrary bar/section jumps, tuplets beyond triplets.

Deferred to v3+: Audio playback / backing tracks, full score notation.
