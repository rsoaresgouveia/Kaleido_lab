import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/face_capture/presentation/pages/analyze_photo_page.dart';
import '../../features/face_capture/presentation/pages/capture_result_page.dart';
import '../../features/face_capture/presentation/pages/face_capture_guide_page.dart';
import '../../features/face_capture/presentation/pages/live_capture_page.dart';
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
          GoRoute(
            path: 'face-capture',
            name: Routes.faceCaptureGuideName,
            builder: (context, state) => const FaceCaptureGuidePage(),
            routes: [
              GoRoute(
                path: 'live',
                name: Routes.faceCaptureLiveName,
                builder: (context, state) => const LiveCapturePage(),
              ),
              GoRoute(
                path: 'result',
                name: Routes.faceCaptureResultName,
                builder: (context, state) =>
                    CaptureResultPage(imagePath: state.extra! as String),
              ),
              GoRoute(
                path: 'analyze',
                name: Routes.faceCaptureAnalyzeName,
                builder: (context, state) => const AnalyzePhotoPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
