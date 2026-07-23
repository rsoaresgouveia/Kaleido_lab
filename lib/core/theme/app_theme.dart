import 'package:flutter/material.dart';

/// Central place that builds the light and dark [ThemeData] from a single seed
/// color, so the whole app stays visually consistent.
abstract final class AppTheme {
  const AppTheme._();

  /// Seed the Material 3 color scheme is derived from.
  static const Color seedColor = Color(0xFF5B4CFF);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
    );
  }
}
