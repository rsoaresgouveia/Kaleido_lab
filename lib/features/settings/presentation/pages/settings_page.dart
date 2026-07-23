import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';

/// Lets the user pick the app theme and language. Both choices are persisted
/// through the settings controller and take effect immediately.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(label: l10n.settingsAppearanceSection),
          RadioGroup<AppThemeMode>(
            groupValue: settings.themeMode,
            onChanged: (value) {
              if (value != null) controller.setThemeMode(value);
            },
            child: Column(
              children: [
                for (final mode in AppThemeMode.values)
                  RadioListTile<AppThemeMode>(
                    value: mode,
                    title: Text(_themeModeLabel(l10n, mode)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _SectionHeader(label: l10n.settingsLanguageSection),
          RadioGroup<AppLanguage>(
            groupValue: settings.language,
            onChanged: (value) {
              if (value != null) controller.setLanguage(value);
            },
            child: Column(
              children: [
                for (final language in AppLanguage.values)
                  RadioListTile<AppLanguage>(
                    value: language,
                    title: Text(_languageLabel(l10n, language)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l10n, AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => l10n.themeModeSystem,
      AppThemeMode.light => l10n.themeModeLight,
      AppThemeMode.dark => l10n.themeModeDark,
    };
  }

  String _languageLabel(AppLocalizations l10n, AppLanguage language) {
    return switch (language) {
      AppLanguage.system => l10n.languageSystem,
      AppLanguage.english => l10n.languageEnglish,
      AppLanguage.portuguese => l10n.languagePortuguese,
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
