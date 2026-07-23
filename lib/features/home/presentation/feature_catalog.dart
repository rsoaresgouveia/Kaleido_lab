import 'package:flutter/material.dart';

import '../../../app/router/routes.dart';
import '../../../core/localization/l10n_extensions.dart';

/// A single entry in the home gallery. New feature demos are added here.
class FeatureEntry {
  const FeatureEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.routeName,
  });

  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) subtitle;
  final String routeName;
}

/// The features surfaced on the home screen.
final List<FeatureEntry> featureCatalog = [
  FeatureEntry(
    icon: Icons.face_retouching_natural,
    title: (l10n) => l10n.featureFaceCaptureTitle,
    subtitle: (l10n) => l10n.featureFaceCaptureSubtitle,
    routeName: Routes.faceCaptureGuideName,
  ),
];
