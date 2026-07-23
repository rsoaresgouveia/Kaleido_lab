import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../domain/entities/compliance.dart';
import '../compliance_l10n.dart';
import '../providers/face_capture_providers.dart';
import '../widgets/compliance_hint_banner.dart';
import '../widgets/face_frame_overlay.dart';

/// Live front-camera capture. Each frame is run through ML Kit and the rules
/// engine; when every rule holds for [_holdDuration], the photo is taken
/// automatically and the user is sent to review it.
class LiveCapturePage extends ConsumerStatefulWidget {
  const LiveCapturePage({super.key});

  @override
  ConsumerState<LiveCapturePage> createState() => _LiveCapturePageState();
}

enum _CameraError { permission, unavailable }

class _LiveCapturePageState extends ConsumerState<LiveCapturePage>
    with WidgetsBindingObserver {
  static const int _tickMs = 50;
  static const int _holdMs = 1500;

  CameraController? _controller;
  bool _initializing = true;
  _CameraError? _error;
  bool _isDetecting = false;
  bool _capturing = false;
  ComplianceReport? _report;
  double _holdProgress = 0;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _holdTimer = Timer.periodic(
      const Duration(milliseconds: _tickMs),
      _onHoldTick,
    );
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _holdTimer?.cancel();
    _disposeController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _disposeController();
      if (mounted) setState(() => _controller = null);
    } else if (state == AppLifecycleState.resumed) {
      _start();
    }
  }

  Future<void> _start() async {
    setState(() {
      _initializing = true;
      _error = null;
    });
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _fail(_CameraError.unavailable);
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.iOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.nv21,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.startImageStream(_onFrame);
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } on CameraException catch (e) {
      _fail(
        e.code == 'CameraAccessDenied'
            ? _CameraError.permission
            : _CameraError.unavailable,
      );
    } catch (_) {
      _fail(_CameraError.unavailable);
    }
  }

  void _fail(_CameraError error) {
    if (!mounted) return;
    setState(() {
      _error = error;
      _initializing = false;
    });
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // Ignore: the controller is being torn down anyway.
    }
    await controller.dispose();
  }

  Future<void> _onFrame(CameraImage frame) async {
    if (_isDetecting || _capturing) return;
    final controller = _controller;
    if (controller == null) return;
    _isDetecting = true;
    try {
      final description = controller.description;
      final sample = await ref
          .read(faceDetectionServiceProvider)
          .analyzeFrame(
            frame: frame,
            sensorOrientation: description.sensorOrientation,
            deviceOrientation: controller.value.deviceOrientation,
            lensDirection: description.lensDirection,
          );
      final report = ref.read(faceComplianceEvaluatorProvider).evaluate(sample);
      if (mounted) setState(() => _report = report);
    } catch (_) {
      // Drop the frame; the next one will be processed.
    } finally {
      _isDetecting = false;
    }
  }

  void _onHoldTick(Timer _) {
    if (!mounted || _capturing || _controller == null) return;
    final compliant = _report?.isCompliant ?? false;
    if (compliant) {
      final next = (_holdProgress + _tickMs / _holdMs).clamp(0.0, 1.0);
      setState(() => _holdProgress = next);
      if (next >= 1.0) _capture();
    } else if (_holdProgress != 0) {
      setState(() => _holdProgress = 0);
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_capturing || controller == null) return;
    setState(() => _capturing = true);
    try {
      await controller.stopImageStream();
      final file = await controller.takePicture();
      if (!mounted) return;
      await context.pushNamed(Routes.faceCaptureResultName, extra: file.path);
    } catch (_) {
      // Fall through and resume the stream.
    } finally {
      if (mounted) {
        setState(() {
          _capturing = false;
          _holdProgress = 0;
          _report = null;
        });
        final controller = _controller;
        if (controller != null &&
            controller.value.isInitialized &&
            !controller.value.isStreamingImages) {
          try {
            await controller.startImageStream(_onFrame);
          } catch (_) {
            // Ignore: nothing more we can do here.
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(l10n.faceCaptureTitle),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;

    if (_error != null) {
      return _ErrorView(
        message: _error == _CameraError.permission
            ? l10n.faceCameraPermissionDenied
            : l10n.faceCameraError,
        retryLabel: l10n.faceCaptureRetry,
        onRetry: _start,
      );
    }

    final controller = _controller;
    if (_initializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final report = _report;
    final compliant = report?.isCompliant ?? false;
    final color = compliant
        ? const Color(0xFF35C759)
        : report == null
        ? Colors.white70
        : const Color(0xFFFFB020);

    final String hint;
    if (compliant) {
      hint = l10n.hintReady;
    } else if (report == null) {
      hint = l10n.hintNoFace;
    } else {
      hint =
          complianceHintText(l10n, report.primaryHint) ??
          l10n.faceCaptureHoldSteady;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _CameraCover(controller: controller),
        FaceFrameOverlay(color: color, progress: _holdProgress),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ComplianceHintBanner(message: hint, compliant: compliant),
            ),
          ),
        ),
        if (_capturing)
          const ColoredBox(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

/// Fills the screen with the camera preview using a cover fit.
class _CameraCover extends StatelessWidget {
  const _CameraCover({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final preview = controller.value.previewSize;
    if (preview == null) {
      return const ColoredBox(color: Colors.black);
    }
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: preview.height,
          height: preview.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography, color: Colors.white70, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
