import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'routes.dart';

/// Application router. Exposed as a provider so features and tests can read or
/// override it through Riverpod.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        name: Routes.homeName,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'settings',
            name: Routes.settingsName,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});
