import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/entities/face_sample.dart';

/// Wraps the ML Kit face detector and turns raw inputs — live camera frames or
/// a still image file — into the framework-agnostic [FaceSample] the domain
/// layer evaluates.
///
/// Everything ML-Kit-, camera-, and platform-specific is contained here.
class FaceDetectionService {
  FaceDetectionService()
    : _detector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableTracking: true,
          minFaceSize: 0.15,
        ),
      );

  final FaceDetector _detector;

  static const Map<DeviceOrientation, int> _deviceOrientationDegrees = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// Detects faces in a live camera [frame] and returns a [FaceSample].
  ///
  /// Returns a face-less sample (still carrying the measured [FaceSample.luminance])
  /// when the frame can't be converted for the current platform/orientation.
  Future<FaceSample> analyzeFrame({
    required CameraImage frame,
    required int sensorOrientation,
    required DeviceOrientation deviceOrientation,
    required CameraLensDirection lensDirection,
  }) async {
    final luminance = _luminanceFromFrame(frame);
    final (inputImage, rotation) = _inputImageFromFrame(
      frame,
      sensorOrientation: sensorOrientation,
      deviceOrientation: deviceOrientation,
      lensDirection: lensDirection,
    );
    if (inputImage == null) {
      return FaceSample(faceCount: 0, luminance: luminance);
    }

    final faces = await _detector.processImage(inputImage);
    final upright =
        rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;
    final width = (upright ? frame.height : frame.width).toDouble();
    final height = (upright ? frame.width : frame.height).toDouble();
    return _toSample(faces, width, height, luminance);
  }

  /// Runs the same rules against a still image on disk (the "analyze a photo"
  /// mode, which needs no camera).
  Future<FaceSample> analyzeImageFile(String path) async {
    final bytes = await File(path).readAsBytes();
    final decoded = await decodeImageFromList(bytes);
    final luminance = await _luminanceFromImage(decoded);
    final faces = await _detectInImage(decoded, fallbackPath: path);
    final sample = _toSample(
      faces,
      decoded.width.toDouble(),
      decoded.height.toDouble(),
      luminance,
    );
    decoded.dispose();
    return sample;
  }

  /// Detects faces on an orientation-normalized copy of [image].
  ///
  /// Front-camera JPEGs carry an EXIF orientation that ML Kit's `fromFilePath`
  /// does not apply on iOS, so the face comes in rotated and goes undetected.
  /// Flutter's decoder already bakes the orientation into [image]; re-encoding
  /// it to a temporary PNG gives ML Kit upright pixels.
  Future<List<Face>> _detectInImage(
    ui.Image image, {
    required String fallbackPath,
  }) async {
    try {
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      if (png != null) {
        final tmp = File(
          '${Directory.systemTemp.path}/kaleido_mlkit_analyze.png',
        );
        await tmp.writeAsBytes(png.buffer.asUint8List(), flush: true);
        final faces = await _detector.processImage(
          InputImage.fromFilePath(tmp.path),
        );
        try {
          await tmp.delete();
        } catch (_) {
          // Best-effort cleanup.
        }
        return faces;
      }
    } catch (_) {
      // Fall back to the original file.
    }
    return _detector.processImage(InputImage.fromFilePath(fallbackPath));
  }

  void dispose() {
    _detector.close();
  }

  FaceSample _toSample(
    List<Face> faces,
    double imageWidth,
    double imageHeight,
    double luminance,
  ) {
    if (faces.isEmpty) {
      return FaceSample(faceCount: 0, luminance: luminance);
    }

    // Describe the largest (closest) face when several are present.
    final face = faces.reduce(
      (a, b) => _area(a.boundingBox) >= _area(b.boundingBox) ? a : b,
    );
    final box = face.boundingBox;
    final hasImage = imageWidth > 0 && imageHeight > 0;
    final widthRatio = hasImage ? box.width / imageWidth : null;

    // Distance of the face-box center from the image center. This is reliable on
    // a still upright image (the authoritative gate); on a live camera frame the
    // sensor-space coordinates are not, which is why live compliance ignores it.
    final cx = hasImage ? box.center.dx / imageWidth : 0.5;
    final cy = hasImage ? box.center.dy / imageHeight : 0.5;
    final centerOffset = math.sqrt(
      (cx - 0.5) * (cx - 0.5) + (cy - 0.5) * (cy - 0.5),
    );

    return FaceSample(
      faceCount: faces.length,
      yawDegrees: face.headEulerAngleY,
      pitchDegrees: face.headEulerAngleX,
      rollDegrees: face.headEulerAngleZ,
      smilingProbability: face.smilingProbability,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
      faceWidthRatio: widthRatio,
      faceCenterOffset: centerOffset,
      luminance: luminance,
    );
  }

  double _area(ui.Rect rect) => rect.width * rect.height;

  (InputImage?, InputImageRotation?) _inputImageFromFrame(
    CameraImage frame, {
    required int sensorOrientation,
    required DeviceOrientation deviceOrientation,
    required CameraLensDirection lensDirection,
  }) {
    InputImageRotation? rotation;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else {
      final deviceDegrees = _deviceOrientationDegrees[deviceOrientation];
      if (deviceDegrees == null) return (null, null);
      final compensated = lensDirection == CameraLensDirection.front
          ? (sensorOrientation + deviceDegrees) % 360
          : (sensorOrientation - deviceDegrees + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(compensated);
    }
    if (rotation == null) return (null, null);

    final format = InputImageFormatValue.fromRawValue(frame.format.raw);
    if (format == null || frame.planes.isEmpty) return (null, rotation);

    final plane = frame.planes.first;
    final inputImage = InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: ui.Size(frame.width.toDouble(), frame.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
    return (inputImage, rotation);
  }

  /// Average brightness of a camera frame, in `0..255`. A pragmatic lighting
  /// proxy: it subsamples the luma (Android NV21) or green channel (iOS BGRA)
  /// rather than every pixel, which is plenty for a "too dark / too bright" cue.
  double _luminanceFromFrame(CameraImage frame) {
    final bytes = frame.planes.first.bytes;
    if (bytes.isEmpty) return 0;

    var sum = 0;
    var count = 0;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // BGRA8888: sample the green channel (offset 1) as a brightness proxy.
      for (var i = 1; i < bytes.length; i += 64) {
        sum += bytes[i];
        count++;
      }
    } else {
      // NV21/YUV: the first width*height bytes are the luma plane.
      final lumaLength = math.min(frame.width * frame.height, bytes.length);
      for (var i = 0; i < lumaLength; i += 16) {
        sum += bytes[i];
        count++;
      }
    }
    return count == 0 ? 0 : sum / count;
  }

  Future<double> _luminanceFromImage(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return 0;
    final bytes = data.buffer.asUint8List();

    var sum = 0.0;
    var count = 0;
    for (var i = 0; i + 2 < bytes.length; i += 128) {
      sum += 0.299 * bytes[i] + 0.587 * bytes[i + 1] + 0.114 * bytes[i + 2];
      count++;
    }
    return count == 0 ? 0 : sum / count;
  }
}
