/// Route paths and names used across the app. Centralised so navigation calls
/// never hard-code raw strings.
abstract final class Routes {
  const Routes._();

  static const String home = '/';
  static const String homeName = 'home';

  static const String settings = '/settings';
  static const String settingsName = 'settings';

  static const String faceCaptureGuideName = 'faceCaptureGuide';
  static const String faceCaptureLiveName = 'faceCaptureLive';
  static const String faceCaptureResultName = 'faceCaptureResult';
  static const String faceCaptureAnalyzeName = 'faceCaptureAnalyze';
}
