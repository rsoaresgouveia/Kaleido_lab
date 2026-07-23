import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/settings_local_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../controllers/settings_controller.dart';

/// Bound to the concrete [SharedPreferences] instance in `main` via an override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) =>
      SharedPreferencesSettingsDataSource(ref.watch(sharedPreferencesProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider)),
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
