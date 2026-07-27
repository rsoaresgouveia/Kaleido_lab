import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/face_detection_service.dart';
import '../../domain/services/face_compliance_evaluator.dart';

/// The ML Kit-backed detector. Disposed with the provider scope so the native
/// detector is always released.
final faceDetectionServiceProvider = Provider<FaceDetectionService>((ref) {
  final service = FaceDetectionService();
  ref.onDispose(service.dispose);
  return service;
});

/// Lenient rules for the live preview (guidance only).
final liveComplianceEvaluatorProvider = Provider<FaceComplianceEvaluator>(
  (ref) => const FaceComplianceEvaluator(ComplianceThresholds.live),
);

/// Strict rules for the captured still — the authoritative gate that decides
/// whether the photo is good enough to send to the backend.
final stillComplianceEvaluatorProvider = Provider<FaceComplianceEvaluator>(
  (ref) => const FaceComplianceEvaluator(ComplianceThresholds.still),
);
