import 'package:flutter/material.dart';

import '../domain/entities/app_settings.dart';

/// Adapts the framework-agnostic domain enums to the Flutter types the
/// `MaterialApp` expects.
extension AppThemeModeMapper on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

extension AppLanguageMapper on AppLanguage {
  /// Returns `null` for [AppLanguage.system] so `MaterialApp` falls back to the
  /// device locale resolution.
  Locale? toLocale() => switch (this) {
    AppLanguage.system => null,
    AppLanguage.english => const Locale('en'),
    AppLanguage.portuguese => const Locale('pt'),
  };
}
