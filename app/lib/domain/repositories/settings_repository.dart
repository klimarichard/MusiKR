import '../models/app_settings.dart';

/// Persistence contract for user [AppSettings].
abstract class SettingsRepository {
  /// Loads the current settings. Returns [AppSettings.defaults()] if not yet saved.
  Future<AppSettings> loadSettings();

  /// Persists [settings].
  Future<void> saveSettings(AppSettings settings);
}
