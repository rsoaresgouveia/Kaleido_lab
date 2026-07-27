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
    this.minFaceWidthRatio = 0.33,
    this.maxFaceWidthRatio = 0.50,
    this.maxCenterOffset = 0.16,
    this.minFaceWidthPx = 0,
    this.minMargin = 0,
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

  /// Max distance of the face center from the calibrated target (normalized).
  final double maxCenterOffset;

  /// Minimum face width in pixels (recognition needs enough face detail).
  final double minFaceWidthPx;

  /// Minimum margin between the face and every image edge, as a fraction of the
  /// side — so the whole face is comfortably inside the frame.
  final double minMargin;

  /// Acceptable average brightness band, in `0..255`.
  final double minLuminance;
  final double maxLuminance;

  /// Live-preview guidance: lenient size, and positional centering disabled
  /// (camera-stream coordinates are not reliable across devices). The user
  /// aligns visually in the oval; acceptance is decided on the captured still.
  static const ComplianceThresholds live = ComplianceThresholds(
    minFaceWidthRatio: 0.22,
    maxFaceWidthRatio: 0.90,
    maxCenterOffset: 10,
  );

  /// Still-photo gate (authoritative). Strict and reliable because a captured,
  /// upright image has well-behaved coordinates on every device — this is what
  /// decides whether the photo may be sent to the backend.
  static const ComplianceThresholds still = ComplianceThresholds(
    minFaceWidthRatio: 0.30,
    maxFaceWidthRatio: 0.75,
    maxCenterOffset: 0.16,
    minFaceWidthPx: 160,
    minMargin: 0.10,
  );
}

/// Pure, deterministic evaluation of a [FaceSample] against the [ComplianceThresholds].
///
/// Has no dependency on ML Kit, the camera, or Flutter, which keeps every rule
/// exhaustively unit-testable.
class FaceComplianceEvaluator {
  const FaceComplianceEvaluator([this.thresholds = ComplianceThresholds.still]);

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

  /// Framing checks the face is at a good distance (size) and centered. With the
  /// live profile [ComplianceThresholds.maxCenterOffset] is large enough to
  /// disable the centering test (camera-stream coordinates are unreliable); the
  /// still profile enforces it against the reliable upright-image center.
  CheckResult _framing(FaceSample s) {
    final width = s.faceWidthRatio;
    final offset = s.faceCenterOffset;
    final widthPx = s.faceWidthPx;
    final margin = s.faceMargin;

    const tooSmall = CheckResult(
      ComplianceCheck.framing,
      false,
      ComplianceHint.moveCloser,
    );
    const tooBig = CheckResult(
      ComplianceCheck.framing,
      false,
      ComplianceHint.moveAway,
    );

    if (width == null || width < thresholds.minFaceWidthRatio) return tooSmall;
    if (thresholds.minFaceWidthPx > 0 &&
        (widthPx == null || widthPx < thresholds.minFaceWidthPx)) {
      return tooSmall;
    }
    if (width > thresholds.maxFaceWidthRatio) return tooBig;
    // Too little margin means the face is cropped/too close to an edge.
    if (thresholds.minMargin > 0 &&
        (margin == null || margin < thresholds.minMargin)) {
      return tooBig;
    }
    if (offset == null || offset > thresholds.maxCenterOffset) {
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
