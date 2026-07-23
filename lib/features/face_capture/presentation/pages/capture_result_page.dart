import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../widgets/photo_compliance_view.dart';

/// Shows the freshly captured photo re-checked against the rules, with the
/// option to retake (back to the camera) or confirm.
class CaptureResultPage extends StatelessWidget {
  const CaptureResultPage({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultTitle)),
      body: PhotoComplianceView(imagePath: imagePath),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.replay),
                label: Text(l10n.resultRetake),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.resultConfirmed)));
                  context.goNamed(Routes.homeName);
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.resultConfirm),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
