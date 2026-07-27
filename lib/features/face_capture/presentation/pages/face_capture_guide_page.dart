import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/localization/l10n_extensions.dart';

/// Onboarding screen that explains the capture requirements before opening the
/// camera. Also offers the camera-free "analyze a photo" path.
class FaceCaptureGuidePage extends StatelessWidget {
  const FaceCaptureGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.faceGuideTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.faceGuideIntro,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _Guideline(icon: Icons.straighten, text: l10n.faceGuideDistance),
            _Guideline(
              icon: Icons.center_focus_strong,
              text: l10n.faceGuideFrontal,
            ),
            _Guideline(
              icon: Icons.wb_sunny_outlined,
              text: l10n.faceGuideLighting,
            ),
            _Guideline(icon: Icons.wallpaper, text: l10n.faceGuideBackground),
            _Guideline(
              icon: Icons.no_accounts,
              text: l10n.faceGuideAccessories,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.faceGuideAccessoriesNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => context.pushNamed(Routes.faceCaptureLiveName),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.faceGuideStartCamera),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed(Routes.faceCaptureAnalyzeName),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.faceGuideAnalyzePhoto),
            ),
          ],
        ),
      ),
    );
  }
}

class _Guideline extends StatelessWidget {
  const _Guideline({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scheme.primaryContainer,
            child: Icon(icon, color: scheme.onPrimaryContainer, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
