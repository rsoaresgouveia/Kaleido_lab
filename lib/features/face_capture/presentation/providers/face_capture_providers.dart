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

/// The pure rules engine. Stateless, so a single const instance is shared.
final faceComplianceEvaluatorProvider = Provider<FaceComplianceEvaluator>(
  (ref) => const FaceComplianceEvaluator(),
);
