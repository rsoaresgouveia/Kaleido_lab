import '../entities/compliance.dart';
import '../entities/face_sample.dart';

/// Tunable limits for each rule. Defaults target an ID-style portrait: a single,
/// centered, front-facing face with a neutral expression, open eyes, and even
/// lighting.
class ComplianceThresholds {
  const ComplianceThresholds({
    this.maxHeadAngleDegrees = 12,
    this.maxSmilingProbability = 0.2,
    this.minEyeOpenProbability = 0.4,
    this.minFaceWidthRatio = 0.30,
    this.maxFaceWidthRatio = 0.80,
    this.maxCenterOffset = 0.18,
    this.minLuminance = 60,
    this.maxLuminance = 235,
  });

  /// Max absolute yaw/pitch/roll, in degrees, still considered "front-facing".
  final double maxHeadAngleDegrees;

  /// Smiling probability at or below this counts as a neutral expression.
  final double maxSmilingProbability;

  /// Each eye must be open with at least this probability.
  final double minEyeOpenProbability;

  /// Acceptable face-width band (fraction of the image width).
  final double minFaceWidthRatio;
  final double maxFaceWidthRatio;

  /// Max normalized distance of the face center from the image center.
  final double maxCenterOffset;

  /// Acceptable average brightness band, in `0..255`.
  final double minLuminance;
  final double maxLuminance;

  static const ComplianceThresholds standard = ComplianceThresholds();
}

/// Pure, deterministic evaluation of a [FaceSample] against the [ComplianceThresholds].
///
/// Has no dependency on ML Kit, the camera, or Flutter, which keeps every rule
/// exhaustively unit-testable.
class FaceComplianceEvaluator {
  const FaceComplianceEvaluator([
    this.thresholds = ComplianceThresholds.standard,
  ]);

  final ComplianceThresholds thresholds;

  ComplianceReport evaluate(FaceSample sample) {
    // With no face in view, nothing else can be assessed.
    if (sample.faceCount == 0) {
      return const ComplianceReport([
        CheckResult(
          ComplianceCheck.singleFace,
          false,
          ComplianceHint.noFaceDetected,
        ),
        CheckResult(ComplianceCheck.framing, false),
        CheckResult(ComplianceCheck.frontal, false),
        CheckResult(ComplianceCheck.eyesOpen, false),
        CheckResult(ComplianceCheck.neutralExpression, false),
        CheckResult(ComplianceCheck.lighting, false),
      ]);
    }

    return ComplianceReport([
      _singleFace(sample),
      _framing(sample),
      _frontal(sample),
      _eyesOpen(sample),
      _neutralExpression(sample),
      _lighting(sample),
    ]);
  }

  CheckResult _singleFace(FaceSample s) {
    if (s.faceCount == 1) {
      return const CheckResult(ComplianceCheck.singleFace, true);
    }
    return const CheckResult(
      ComplianceCheck.singleFace,
      false,
      ComplianceHint.multipleFaces,
    );
  }

  CheckResult _framing(FaceSample s) {
    final width = s.faceWidthRatio;
    final offset = s.faceCenterOffset;
    if (width == null || offset == null) {
      return const CheckResult(
        ComplianceCheck.framing,
        false,
        ComplianceHint.centerFace,
      );
    }
    if (width < thresholds.minFaceWidthRatio) {
      return const CheckResult(
        ComplianceCheck.framing,
        false,
        ComplianceHint.moveCloser,
      );
    }
    if (width > thresholds.maxFaceWidthRatio) {
      return const CheckResult(
        ComplianceCheck.framing,
        false,
        ComplianceHint.moveAway,
      );
    }
    if (offset > thresholds.maxCenterOffset) {
      return const CheckResult(
        ComplianceCheck.framing,
        false,
        ComplianceHint.centerFace,
      );
    }
    return const CheckResult(ComplianceCheck.framing, true);
  }

  CheckResult _frontal(FaceSample s) {
    final yaw = s.yawDegrees;
    final pitch = s.pitchDegrees;
    final roll = s.rollDegrees;
    final limit = thresholds.maxHeadAngleDegrees;
    final ok =
        yaw != null &&
        pitch != null &&
        roll != null &&
        yaw.abs() <= limit &&
        pitch.abs() <= limit &&
        roll.abs() <= limit;
    return CheckResult(
      ComplianceCheck.frontal,
      ok,
      ok ? ComplianceHint.none : ComplianceHint.faceForward,
    );
  }

  CheckResult _eyesOpen(FaceSample s) {
    final left = s.leftEyeOpenProbability;
    final right = s.rightEyeOpenProbability;
    final ok =
        left != null &&
        right != null &&
        left >= thresholds.minEyeOpenProbability &&
        right >= thresholds.minEyeOpenProbability;
    return CheckResult(
      ComplianceCheck.eyesOpen,
      ok,
      ok ? ComplianceHint.none : ComplianceHint.openEyes,
    );
  }

  CheckResult _neutralExpression(FaceSample s) {
    final smiling = s.smilingProbability;
    final ok = smiling != null && smiling <= thresholds.maxSmilingProbability;
    return CheckResult(
      ComplianceCheck.neutralExpression,
      ok,
      ok ? ComplianceHint.none : ComplianceHint.neutralExpression,
    );
  }

  CheckResult _lighting(FaceSample s) {
    final lum = s.luminance;
    if (lum == null) {
      return const CheckResult(
        ComplianceCheck.lighting,
        false,
        ComplianceHint.tooDark,
      );
    }
    if (lum < thresholds.minLuminance) {
      return const CheckResult(
        ComplianceCheck.lighting,
        false,
        ComplianceHint.tooDark,
      );
    }
    if (lum > thresholds.maxLuminance) {
      return const CheckResult(
        ComplianceCheck.lighting,
        false,
        ComplianceHint.tooBright,
      );
    }
    return const CheckResult(ComplianceCheck.lighting, true);
  }
}
