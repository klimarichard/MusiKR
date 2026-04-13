import '../../domain/models/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// In-memory implementation of [SettingsRepository] for Phase 1.
class InMemorySettingsRepository implements SettingsRepository {
  AppSettings _settings = AppSettings.defaults();

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}
