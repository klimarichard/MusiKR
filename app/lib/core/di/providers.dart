import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/in_memory_song_repository.dart';
import '../../data/repositories/in_memory_settings_repository.dart';
import '../../domain/repositories/song_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/chord_parser.dart';
import '../../domain/services/layout_engine.dart';
import '../../domain/services/repeat_validator.dart';
import '../../domain/use_cases/create_song_use_case.dart';
import '../../domain/use_cases/update_chord_use_case.dart';
import '../../domain/use_cases/insert_bar_use_case.dart';
import '../../domain/use_cases/delete_bar_use_case.dart';
import '../../domain/use_cases/insert_section_use_case.dart';
import '../../domain/use_cases/delete_section_use_case.dart';
import '../../domain/use_cases/update_repeat_info_use_case.dart';
import '../../domain/use_cases/update_metadata_use_case.dart';

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

/// Provides the [SongRepository] implementation.
/// Override in tests: ProviderContainer(overrides: [songRepositoryProvider.overrideWithValue(mockRepo)])
final songRepositoryProvider = Provider<SongRepository>(
  (ref) => InMemorySongRepository(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => InMemorySettingsRepository(),
);

// ---------------------------------------------------------------------------
// Use cases
// ---------------------------------------------------------------------------

final createSongUseCaseProvider = Provider<CreateSongUseCase>(
  (ref) => CreateSongUseCase(),
);

final updateChordUseCaseProvider = Provider<UpdateChordUseCase>(
  (ref) => UpdateChordUseCase(),
);

final insertBarUseCaseProvider = Provider<InsertBarUseCase>(
  (ref) => InsertBarUseCase(),
);

final deleteBarUseCaseProvider = Provider<DeleteBarUseCase>(
  (ref) => DeleteBarUseCase(),
);

final insertSectionUseCaseProvider = Provider<InsertSectionUseCase>(
  (ref) => InsertSectionUseCase(),
);

final deleteSectionUseCaseProvider = Provider<DeleteSectionUseCase>(
  (ref) => DeleteSectionUseCase(),
);

final updateRepeatInfoUseCaseProvider = Provider<UpdateRepeatInfoUseCase>(
  (ref) => UpdateRepeatInfoUseCase(),
);

final updateMetadataUseCaseProvider = Provider<UpdateMetadataUseCase>(
  (ref) => UpdateMetadataUseCase(),
);

// ---------------------------------------------------------------------------
// Domain services
// ---------------------------------------------------------------------------

final chordParserProvider = Provider<ChordParser>(
  (ref) => const ChordParser(),
);

final layoutEngineProvider = Provider<LayoutEngine>(
  (ref) => const LayoutEngine(),
);

final repeatValidatorProvider = Provider<RepeatValidator>(
  (ref) => const RepeatValidator(),
);
