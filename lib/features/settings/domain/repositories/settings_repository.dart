import '../entities/app_settings.dart';

/// Boundary between the settings feature and whatever persists its state.
///
/// Reads are synchronous because the backing store is loaded once at startup;
/// writes are asynchronous because they hit persistent storage.
abstract interface class SettingsRepository {
  /// Returns the persisted settings, falling back to [AppSettings.initial].
  AppSettings load();

  Future<void> saveThemeMode(AppThemeMode mode);

  Future<void> saveLanguage(AppLanguage language);
}
