import 'package:flutter_test/flutter_test.dart';
import 'package:kaleido_lab/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:kaleido_lab/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:kaleido_lab/features/settings/domain/entities/app_settings.dart';

/// In-memory [SettingsLocalDataSource] so the repository can be tested without
/// touching real storage.
class _InMemoryDataSource implements SettingsLocalDataSource {
  String? themeMode;
  String? language;

  @override
  String? readThemeMode() => themeMode;

  @override
  String? readLanguage() => language;

  @override
  Future<void> writeThemeMode(String value) async => themeMode = value;

  @override
  Future<void> writeLanguage(String value) async => language = value;
}

void main() {
  late _InMemoryDataSource dataSource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    dataSource = _InMemoryDataSource();
    repository = SettingsRepositoryImpl(dataSource);
  });

  test('load falls back to the initial settings when nothing is stored', () {
    expect(repository.load(), AppSettings.initial);
  });

  test('load decodes stored values back into domain enums', () {
    dataSource
      ..themeMode = 'dark'
      ..language = 'portuguese';

    expect(
      repository.load(),
      const AppSettings(
        themeMode: AppThemeMode.dark,
        language: AppLanguage.portuguese,
      ),
    );
  });

  test('load ignores unknown stored values and uses the defaults', () {
    dataSource
      ..themeMode = 'not-a-mode'
      ..language = 'klingon';

    expect(repository.load(), AppSettings.initial);
  });

  test('saving persists the enum name', () async {
    await repository.saveThemeMode(AppThemeMode.light);
    await repository.saveLanguage(AppLanguage.english);

    expect(dataSource.themeMode, 'light');
    expect(dataSource.language, 'english');
  });
}
