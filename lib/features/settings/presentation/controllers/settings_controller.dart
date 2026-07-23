import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../providers/settings_providers.dart';

/// Owns the live [AppSettings] state and persists every change.
///
/// State updates are applied optimistically so the UI reacts immediately; the
/// write to storage happens right after.
class SettingsController extends Notifier<AppSettings> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() => _repository.load();

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (state.themeMode == mode) return;
    state = state.copyWith(themeMode: mode);
    await _repository.saveThemeMode(mode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state.language == language) return;
    state = state.copyWith(language: language);
    await _repository.saveLanguage(language);
  }
}
