import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

/// Translates between the persisted string representation and the domain enums.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource);

  final SettingsLocalDataSource _dataSource;

  @override
  AppSettings load() {
    return AppSettings(
      themeMode: _decodeThemeMode(_dataSource.readThemeMode()),
      language: _decodeLanguage(_dataSource.readLanguage()),
    );
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) =>
      _dataSource.writeThemeMode(mode.name);

  @override
  Future<void> saveLanguage(AppLanguage language) =>
      _dataSource.writeLanguage(language.name);

  AppThemeMode _decodeThemeMode(String? raw) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => AppSettings.initial.themeMode,
    );
  }

  AppLanguage _decodeLanguage(String? raw) {
    return AppLanguage.values.firstWhere(
      (language) => language.name == raw,
      orElse: () => AppSettings.initial.language,
    );
  }
}
