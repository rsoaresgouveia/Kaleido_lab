import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../domain/entities/compliance.dart';
import '../../domain/entities/face_sample.dart';
import '../providers/face_capture_providers.dart';
import 'compliance_checklist.dart';

/// Analyzes a still image at [imagePath] against the compliance rules and shows
/// the photo, an overall verdict, and the per-check breakdown. Shared by the
/// live-capture review screen and the "analyze a photo" screen.
class PhotoComplianceView extends ConsumerStatefulWidget {
  const PhotoComplianceView({super.key, required this.imagePath});

  final String imagePath;

  @override
  ConsumerState<PhotoComplianceView> createState() =>
      _PhotoComplianceViewState();
}

class _PhotoComplianceViewState extends ConsumerState<PhotoComplianceView> {
  late Future<_Analysis> _analysis;

  @override
  void initState() {
    super.initState();
    _analysis = _analyze();
  }

  @override
  void didUpdateWidget(PhotoComplianceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _analysis = _analyze();
    }
  }

  Future<_Analysis> _analyze() async {
    final sample = await ref
        .read(faceDetectionServiceProvider)
        .analyzeImageFile(widget.imagePath);
    final report = ref.read(faceComplianceEvaluatorProvider).evaluate(sample);
    return _Analysis(sample, report);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(widget.imagePath),
            height: 320,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<_Analysis>(
          future: _analysis,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _Centered(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l10n.analyzing),
                  ],
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _Centered(child: Text(l10n.faceCameraError));
            }

            final analysis = snapshot.data!;
            if (analysis.sample.faceCount == 0) {
              return _Centered(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.face_retouching_off,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: Text(l10n.analyzeNoFace)),
                  ],
                ),
              );
            }

            return _Verdict(report: analysis.report);
          },
        ),
      ],
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.report});

  final ComplianceReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final compliant = report.isCompliant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              compliant ? Icons.verified : Icons.error_outline,
              color: compliant ? Colors.green : scheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                compliant ? l10n.resultCompliant : l10n.resultNotCompliant,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.checksPassedCount(report.passedCount, report.totalCount),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        ComplianceChecklist(report: report),
      ],
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(child: child),
    );
  }
}

class _Analysis {
  const _Analysis(this.sample, this.report);

  final FaceSample sample;
  final ComplianceReport report;
}
