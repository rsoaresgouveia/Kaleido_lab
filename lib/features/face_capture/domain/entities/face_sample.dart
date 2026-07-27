/// A framework-agnostic snapshot of the face attributes the compliance rules
/// need. It is produced from an ML Kit detection (or a still image) in the data
/// layer, but carries no dependency on ML Kit, the camera, or Flutter — so the
/// evaluation logic stays pure and unit-testable.
///
/// When more than one face is present, the fields describe the largest
/// (closest) face; [faceCount] still reports the total so the "single face"
/// rule can react.
class FaceSample {
  const FaceSample({
    required this.faceCount,
    this.yawDegrees,
    this.pitchDegrees,
    this.rollDegrees,
    this.smilingProbability,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.faceWidthRatio,
    this.faceCenterOffset,
    this.faceWidthPx,
    this.faceMargin,
    this.luminance,
  });

  /// No face in view.
  const FaceSample.empty()
    : faceCount = 0,
      yawDegrees = null,
      pitchDegrees = null,
      rollDegrees = null,
      smilingProbability = null,
      leftEyeOpenProbability = null,
      rightEyeOpenProbability = null,
      faceWidthRatio = null,
      faceCenterOffset = null,
      faceWidthPx = null,
      faceMargin = null,
      luminance = null;

  /// Total number of faces detected in the frame.
  final int faceCount;

  /// Head rotation around the vertical axis (turning left/right), in degrees.
  final double? yawDegrees;

  /// Head rotation around the horizontal axis (nodding up/down), in degrees.
  final double? pitchDegrees;

  /// Head tilt (ear-to-shoulder), in degrees.
  final double? rollDegrees;

  /// Probability the face is smiling, in `0..1`.
  final double? smilingProbability;

  /// Probability the left eye is open, in `0..1`.
  final double? leftEyeOpenProbability;

  /// Probability the right eye is open, in `0..1`.
  final double? rightEyeOpenProbability;

  /// Face bounding-box width divided by the image width, in `0..1`.
  final double? faceWidthRatio;

  /// Distance of the face-box center from the image center, normalized by the
  /// image width (`0` = perfectly centered).
  final double? faceCenterOffset;

  /// Face bounding-box width in pixels (used for the recognition minimum).
  final double? faceWidthPx;

  /// Smallest gap between the face box and any image edge, as a fraction of that
  /// side (`>= 0.10` means at least a 10% margin all around).
  final double? faceMargin;

  /// Average brightness of the face region, in `0..255`.
  final double? luminance;
}
