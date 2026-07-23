import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../feature_catalog.dart';

/// The gallery entry point: a list of the available feature demos. Falls back to
/// an empty state when no features are registered yet.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.pushNamed(Routes.settingsName),
          ),
        ],
      ),
      body: featureCatalog.isEmpty
          ? _EmptyState(l10n: l10n)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: featureCatalog.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _FeatureCard(entry: featureCatalog[index]),
            ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.entry});

  final FeatureEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: scheme.primaryContainer,
          child: Icon(entry.icon, color: scheme.onPrimaryContainer),
        ),
        title: Text(entry.title(l10n)),
        subtitle: Text(entry.subtitle(l10n)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.pushNamed(entry.routeName),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.homeEmptyStateTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homeEmptyStateMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
