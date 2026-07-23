import 'package:flutter/material.dart';

/// A rounded pill that shows the current guidance, cross-fading as it changes.
/// Turns positive (green + check) once every rule is satisfied.
class ComplianceHintBanner extends StatelessWidget {
  const ComplianceHintBanner({
    super.key,
    required this.message,
    required this.compliant,
  });

  final String message;
  final bool compliant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = compliant
        ? scheme.primary
        : Colors.black.withValues(alpha: 0.6);
    final foreground = compliant ? scheme.onPrimary : Colors.white;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey('$message-$compliant'),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              compliant ? Icons.check_circle : Icons.center_focus_weak,
              color: foreground,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
