import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../domain/entities/compliance.dart';
import '../widgets/photo_compliance_view.dart';

/// Reviews the freshly captured photo. The photo is re-checked with the strict
/// still rules (the authoritative, device-agnostic gate), and can only be
/// accepted — i.e. sent onward to the backend — once it complies.
class CaptureResultPage extends StatefulWidget {
  const CaptureResultPage({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<CaptureResultPage> createState() => _CaptureResultPageState();
}

class _CaptureResultPageState extends State<CaptureResultPage> {
  ComplianceReport? _report;

  bool get _compliant => _report?.isCompliant ?? false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultTitle)),
      body: PhotoComplianceView(
        imagePath: widget.imagePath,
        onReport: (report) => setState(() => _report = report),
      ),
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
                // Enabled only when the still passes the strict gate.
                onPressed: _compliant
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.resultConfirmed)),
                        );
                        context.goNamed(Routes.homeName);
                      }
                    : null,
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
