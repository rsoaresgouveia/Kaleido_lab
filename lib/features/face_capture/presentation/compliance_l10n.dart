import '../../../core/localization/l10n_extensions.dart';
import '../domain/entities/compliance.dart';

/// Localized label for a compliance check (used in the checklist).
String complianceCheckLabel(AppLocalizations l10n, ComplianceCheck check) {
  return switch (check) {
    ComplianceCheck.singleFace => l10n.checkSingleFace,
    ComplianceCheck.framing => l10n.checkFraming,
    ComplianceCheck.frontal => l10n.checkFrontal,
    ComplianceCheck.eyesOpen => l10n.checkEyesOpen,
    ComplianceCheck.neutralExpression => l10n.checkNeutralExpression,
    ComplianceCheck.lighting => l10n.checkLighting,
  };
}

/// Localized guidance for a hint, or `null` for [ComplianceHint.none].
String? complianceHintText(AppLocalizations l10n, ComplianceHint hint) {
  return switch (hint) {
    ComplianceHint.none => null,
    ComplianceHint.noFaceDetected => l10n.hintNoFace,
    ComplianceHint.multipleFaces => l10n.hintMultipleFaces,
    ComplianceHint.moveCloser => l10n.hintMoveCloser,
    ComplianceHint.moveAway => l10n.hintMoveAway,
    ComplianceHint.centerFace => l10n.hintCenterFace,
    ComplianceHint.faceForward => l10n.hintFaceForward,
    ComplianceHint.openEyes => l10n.hintOpenEyes,
    ComplianceHint.neutralExpression => l10n.hintNeutralExpression,
    ComplianceHint.tooDark => l10n.hintTooDark,
    ComplianceHint.tooBright => l10n.hintTooBright,
  };
}
