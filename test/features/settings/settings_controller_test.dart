import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaleido_lab/features/settings/domain/entities/app_settings.dart';
import 'package:kaleido_lab/features/settings/presentation/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container(Map<String, Object> seed) async {
  SharedPreferences.setMockInitialValues(seed);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts from the persisted settings', () async {
    final container = await _container({'settings.theme_mode': 'dark'});

    expect(
      container.read(settingsControllerProvider).themeMode,
      AppThemeMode.dark,
    );
  });

  test('setThemeMode updates state and persists', () async {
    final container = await _container({});
    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setThemeMode(AppThemeMode.light);

    expect(
      container.read(settingsControllerProvider).themeMode,
      AppThemeMode.light,
    );
    // A fresh controller reading the same store observes the persisted value.
    expect(controller.build().themeMode, AppThemeMode.light);
  });

  test('setLanguage updates state and persists', () async {
    final container = await _container({});
    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setLanguage(AppLanguage.portuguese);

    expect(
      container.read(settingsControllerProvider).language,
      AppLanguage.portuguese,
    );
  });
}
