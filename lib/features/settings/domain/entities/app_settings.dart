/// Theme preference, kept independent of Flutter's `ThemeMode` so the domain
/// layer never depends on the framework.
enum AppThemeMode { system, light, dark }

/// Language preference. `system` follows the device locale; the others pin the
/// app to a specific supported language.
enum AppLanguage { system, english, portuguese }

/// Immutable snapshot of the user's application preferences.
class AppSettings {
  const AppSettings({required this.themeMode, required this.language});

  /// Defaults applied on a fresh install: follow the device for both.
  static const AppSettings initial = AppSettings(
    themeMode: AppThemeMode.system,
    language: AppLanguage.system,
  );

  final AppThemeMode themeMode;
  final AppLanguage language;

  AppSettings copyWith({AppThemeMode? themeMode, AppLanguage? language}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.language == language;

  @override
  int get hashCode => Object.hash(themeMode, language);

  @override
  String toString() =>
      'AppSettings(themeMode: $themeMode, language: $language)';
}
