import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A full-screen scrim with an oval cut-out that the user aligns their face
/// into. The oval border is tinted by [color] (searching / adjusting /
/// compliant) and a progress arc sweeps around it while the capture is held.
class FaceFrameOverlay extends StatelessWidget {
  const FaceFrameOverlay({
    super.key,
    required this.color,
    required this.progress,
  });

  /// Current border/arc color, animated by the caller.
  final Color color;

  /// Hold-to-capture progress, in `0..1`.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _FaceFramePainter(color: color, progress: progress),
      ),
    );
  }
}

class _FaceFramePainter extends CustomPainter {
  _FaceFramePainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = _ovalRect(size);

    // Dim everything except the oval cut-out.
    final scrim = Path()
      ..addRect(Offset.zero & size)
      ..addOval(rect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      scrim,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // The oval guide border.
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color.withValues(alpha: 0.9),
    );

    // Progress arc sweeping clockwise from the top.
    if (progress > 0) {
      canvas.drawArc(
        rect.deflate(2),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
  }

  Rect _ovalRect(Size size) {
    final rx = size.width * 0.36;
    final ry = size.height * 0.28;
    final center = Offset(size.width / 2, size.height * 0.44);
    return Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
  }

  @override
  bool shouldRepaint(_FaceFramePainter old) =>
      old.color != color || old.progress != progress;
}
