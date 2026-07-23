import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../widgets/photo_compliance_view.dart';

/// Camera-free path: pick a photo from the gallery and run it through the exact
/// same rules the live camera uses. Handy for studying the checks and for
/// verifying the flow without a physical camera.
class AnalyzePhotoPage extends ConsumerStatefulWidget {
  const AnalyzePhotoPage({super.key});

  @override
  ConsumerState<AnalyzePhotoPage> createState() => _AnalyzePhotoPageState();
}

class _AnalyzePhotoPageState extends ConsumerState<AnalyzePhotoPage> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pick() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _imagePath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final path = _imagePath;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analyzeTitle)),
      body: path == null
          ? _EmptyState(onPick: _pick)
          : PhotoComplianceView(imagePath: path),
      floatingActionButton: path == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _pick,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.analyzeAnother),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_search, size: 56, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.analyzeEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.analyzePick),
            ),
          ],
        ),
      ),
    );
  }
}
