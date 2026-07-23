/// The individual requirements a capture must satisfy.
enum ComplianceCheck {
  singleFace,
  framing,
  frontal,
  eyesOpen,
  neutralExpression,
  lighting,
}

/// A short, actionable reason a check is failing. The presentation layer maps
/// these to localized guidance; the domain stays language-agnostic.
enum ComplianceHint {
  none,
  noFaceDetected,
  multipleFaces,
  moveCloser,
  moveAway,
  centerFace,
  faceForward,
  openEyes,
  neutralExpression,
  tooDark,
  tooBright,
}

/// Outcome of a single [ComplianceCheck].
class CheckResult {
  const CheckResult(this.check, this.passed, [this.hint = ComplianceHint.none]);

  final ComplianceCheck check;
  final bool passed;
  final ComplianceHint hint;
}

/// Aggregated outcome of evaluating a [FaceSample] against every check.
///
/// [results] is ordered by priority, so [primaryHint] surfaces the most
/// important thing for the user to fix next.
class ComplianceReport {
  const ComplianceReport(this.results);

  final List<CheckResult> results;

  /// True only when every check passes.
  bool get isCompliant => results.every((r) => r.passed);

  /// Number of checks currently satisfied.
  int get passedCount => results.where((r) => r.passed).length;

  int get totalCount => results.length;

  /// The highest-priority actionable hint, or [ComplianceHint.none] when
  /// compliant.
  ComplianceHint get primaryHint {
    for (final result in results) {
      if (!result.passed && result.hint != ComplianceHint.none) {
        return result.hint;
      }
    }
    return ComplianceHint.none;
  }

  bool isPassed(ComplianceCheck check) =>
      results.any((r) => r.check == check && r.passed);
}
