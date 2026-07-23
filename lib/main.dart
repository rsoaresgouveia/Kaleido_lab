import 'package:flutter/material.dart';

void main() => runApp(const KaleidoLabApp());

/// Minimal application shell. Replaced as the real architecture lands.
class KaleidoLabApp extends StatelessWidget {
  const KaleidoLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Kaleido Lab',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Kaleido Lab'))),
    );
  }
}
