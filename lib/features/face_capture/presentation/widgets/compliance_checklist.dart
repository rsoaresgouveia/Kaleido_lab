import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../domain/entities/compliance.dart';
import '../compliance_l10n.dart';

/// Renders each [ComplianceCheck] with a pass/fail indicator. Used on the
/// review and analyze screens.
class ComplianceChecklist extends StatelessWidget {
  const ComplianceChecklist({super.key, required this.report});

  final ComplianceReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final result in report.results)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  result.passed ? Icons.check_circle : Icons.cancel,
                  color: result.passed ? Colors.green : scheme.error,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    complianceCheckLabel(l10n, result.check),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
