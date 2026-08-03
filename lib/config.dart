/// Central configuration for the app.
///
/// Override at build time with `--dart-define`:
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.example.com \
///             --dart-define=USE_DUMMY=false
/// ```
class AppConfig {
  /// Root URL for the Spring Boot backend. No trailing slash.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// When true the app reads from `assets/dummy/data.json` (offline demo mode).
  /// Flip to false once the backend is reachable.
  static const bool useDummyData = bool.fromEnvironment(
    'USE_DUMMY',
    defaultValue: true,
  );

  /// Bearer token attached to every outbound request. Set after login.
  static String? authToken;
}
