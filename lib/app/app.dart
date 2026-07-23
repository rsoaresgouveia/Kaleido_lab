import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/l10n_extensions.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import '../features/settings/presentation/settings_mappers.dart';
import 'router/app_router.dart';

/// Root widget. Wires the router, the localized title, and the theme/locale
/// that the settings controller drives.
class KaleidoApp extends ConsumerWidget {
  const KaleidoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode.toThemeMode(),
      locale: settings.language.toLocale(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
