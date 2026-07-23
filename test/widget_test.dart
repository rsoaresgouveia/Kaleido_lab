import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaleido_lab/app/app.dart';
import 'package:kaleido_lab/features/settings/presentation/pages/settings_page.dart';
import 'package:kaleido_lab/features/settings/presentation/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _bootApp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const KaleidoApp(),
  );
}

void main() {
  testWidgets('home renders the app title and the empty state', (tester) async {
    await tester.pumpWidget(await _bootApp());
    await tester.pumpAndSettle();

    expect(find.text('Kaleido Lab'), findsOneWidget);
    expect(find.text('No features yet'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('tapping the settings action opens the settings page', (
    tester,
  ) async {
    await tester.pumpWidget(await _bootApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
