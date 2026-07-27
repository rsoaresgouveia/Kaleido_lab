import 'package:flutter_test/flutter_test.dart';
import 'package:kaleido_lab/features/face_capture/domain/entities/compliance.dart';
import 'package:kaleido_lab/features/face_capture/domain/entities/face_sample.dart';
import 'package:kaleido_lab/features/face_capture/domain/services/face_compliance_evaluator.dart';

/// A sample that satisfies every rule; individual tests override one field to
/// isolate a single failing dimension.
FaceSample compliantSample({
  int faceCount = 1,
  double yaw = 2,
  double pitch = -3,
  double roll = 1,
  double smiling = 0.05,
  double leftEye = 0.9,
  double rightEye = 0.92,
  double width = 0.42,
  double centerOffset = 0.04,
  double widthPx = 300,
  double margin = 0.2,
  double luminance = 140,
}) {
  return FaceSample(
    faceCount: faceCount,
    yawDegrees: yaw,
    pitchDegrees: pitch,
    rollDegrees: roll,
    smilingProbability: smiling,
    leftEyeOpenProbability: leftEye,
    rightEyeOpenProbability: rightEye,
    faceWidthRatio: width,
    faceCenterOffset: centerOffset,
    faceWidthPx: widthPx,
    faceMargin: margin,
    luminance: luminance,
  );
}

void main() {
  const evaluator = FaceComplianceEvaluator();

  test('a well-formed sample passes every check', () {
    final report = evaluator.evaluate(compliantSample());

    expect(report.isCompliant, isTrue);
    expect(report.passedCount, report.totalCount);
    expect(report.primaryHint, ComplianceHint.none);
  });

  test('no face fails everything and hints to show a face', () {
    final report = evaluator.evaluate(const FaceSample.empty());

    expect(report.isCompliant, isFalse);
    expect(report.passedCount, 0);
    expect(report.primaryHint, ComplianceHint.noFaceDetected);
  });

  test('multiple faces fail only the single-face rule', () {
    final report = evaluator.evaluate(compliantSample(faceCount: 2));

    expect(report.isCompliant, isFalse);
    expect(report.isPassed(ComplianceCheck.singleFace), isFalse);
    expect(report.isPassed(ComplianceCheck.frontal), isTrue);
    expect(report.primaryHint, ComplianceHint.multipleFaces);
  });

  group('framing', () {
    test('a face that is too small asks the user to move closer', () {
      final report = evaluator.evaluate(compliantSample(width: 0.2));
      expect(report.isPassed(ComplianceCheck.framing), isFalse);
      expect(report.primaryHint, ComplianceHint.moveCloser);
    });

    test('a face that is too large asks the user to move away', () {
      final report = evaluator.evaluate(compliantSample(width: 0.9));
      expect(report.isPassed(ComplianceCheck.framing), isFalse);
      expect(report.primaryHint, ComplianceHint.moveAway);
    });

    test('a face far from the target asks the user to center it', () {
      final report = evaluator.evaluate(compliantSample(centerOffset: 0.3));
      expect(report.isPassed(ComplianceCheck.framing), isFalse);
      expect(report.primaryHint, ComplianceHint.centerFace);
    });

    test('a face below the pixel minimum asks the user to move closer', () {
      final report = evaluator.evaluate(compliantSample(widthPx: 120));
      expect(report.isPassed(ComplianceCheck.framing), isFalse);
      expect(report.primaryHint, ComplianceHint.moveCloser);
    });

    test('too little margin around the face asks the user to move away', () {
      final report = evaluator.evaluate(compliantSample(margin: 0.05));
      expect(report.isPassed(ComplianceCheck.framing), isFalse);
      expect(report.primaryHint, ComplianceHint.moveAway);
    });
  });

  group('frontal pose', () {
    test('a large yaw fails the frontal check', () {
      final report = evaluator.evaluate(compliantSample(yaw: 25));
      expect(report.isPassed(ComplianceCheck.frontal), isFalse);
      expect(report.primaryHint, ComplianceHint.faceForward);
    });

    test('a tilted head (roll) fails the frontal check', () {
      final report = evaluator.evaluate(compliantSample(roll: -20));
      expect(report.isPassed(ComplianceCheck.frontal), isFalse);
    });

    test('an angle exactly at the limit still passes', () {
      final report = evaluator.evaluate(compliantSample(yaw: 12, pitch: -12));
      expect(report.isPassed(ComplianceCheck.frontal), isTrue);
    });
  });

  test('a smile fails the neutral-expression check', () {
    final report = evaluator.evaluate(compliantSample(smiling: 0.8));
    expect(report.isPassed(ComplianceCheck.neutralExpression), isFalse);
    // Framing/frontal still pass, so the smile is the surfaced hint.
    expect(report.primaryHint, ComplianceHint.neutralExpression);
  });

  test('a closed eye fails the eyes-open check', () {
    final report = evaluator.evaluate(compliantSample(rightEye: 0.1));
    expect(report.isPassed(ComplianceCheck.eyesOpen), isFalse);
    expect(report.primaryHint, ComplianceHint.openEyes);
  });

  group('lighting', () {
    test('a dark frame is flagged as too dark', () {
      final report = evaluator.evaluate(compliantSample(luminance: 30));
      expect(report.isPassed(ComplianceCheck.lighting), isFalse);
      expect(report.primaryHint, ComplianceHint.tooDark);
    });

    test('a blown-out frame is flagged as too bright', () {
      final report = evaluator.evaluate(compliantSample(luminance: 250));
      expect(report.isPassed(ComplianceCheck.lighting), isFalse);
      expect(report.primaryHint, ComplianceHint.tooBright);
    });
  });

  test('hint priority favors framing over expression', () {
    // Both framing and expression fail; framing is more fundamental.
    final report = evaluator.evaluate(
      compliantSample(width: 0.2, smiling: 0.9),
    );
    expect(report.primaryHint, ComplianceHint.moveCloser);
  });

  test('custom thresholds are honored', () {
    const strict = FaceComplianceEvaluator(
      ComplianceThresholds(maxSmilingProbability: 0.01),
    );
    final report = strict.evaluate(compliantSample(smiling: 0.05));
    expect(report.isPassed(ComplianceCheck.neutralExpression), isFalse);
  });
}
