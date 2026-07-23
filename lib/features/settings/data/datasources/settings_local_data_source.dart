import 'package:shared_preferences/shared_preferences.dart';

/// Raw string-keyed access to the persisted settings. Kept deliberately dumb:
/// it only reads and writes strings and knows nothing about the domain enums.
abstract interface class SettingsLocalDataSource {
  String? readThemeMode();

  String? readLanguage();

  Future<void> writeThemeMode(String value);

  Future<void> writeLanguage(String value);
}

/// [SettingsLocalDataSource] backed by [SharedPreferences].
class SharedPreferencesSettingsDataSource implements SettingsLocalDataSource {
  SharedPreferencesSettingsDataSource(this._prefs);

  static const String _themeModeKey = 'settings.theme_mode';
  static const String _languageKey = 'settings.language';

  final SharedPreferences _prefs;

  @override
  String? readThemeMode() => _prefs.getString(_themeModeKey);

  @override
  String? readLanguage() => _prefs.getString(_languageKey);

  @override
  Future<void> writeThemeMode(String value) =>
      _prefs.setString(_themeModeKey, value);

  @override
  Future<void> writeLanguage(String value) =>
      _prefs.setString(_languageKey, value);
}
