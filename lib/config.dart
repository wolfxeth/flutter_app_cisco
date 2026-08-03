import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central configuration for the app.
///
/// Compile-time defaults can be set with `--dart-define`:
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.example.com \
///             --dart-define=USE_DUMMY=false
/// ```
/// At runtime the user can override both from the in-app settings sheet; the
/// choice is persisted with shared_preferences so it survives restarts.
class AppConfig {
  // -- Compile-time fallbacks ----------------------------------------------

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const bool _defaultUseDummy = bool.fromEnvironment(
    'USE_DUMMY',
    defaultValue: true,
  );

  static const String _kUseDummy = 'use_dummy_data';
  static const String _kBaseUrl = 'api_base_url';

  // -- Runtime, listenable state -------------------------------------------

  /// true = read from `assets/dummy/data.json` (offline demo), false = live API.
  static final ValueNotifier<bool> useDummy =
      ValueNotifier<bool>(_defaultUseDummy);

  /// Root URL for the Spring Boot backend. No trailing slash.
  static final ValueNotifier<String> baseUrl =
      ValueNotifier<String>(_defaultBaseUrl);

  static SharedPreferences? _prefs;

  /// Loads persisted settings. Call once before `runApp`.
  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _prefs = p;
    useDummy.value = p.getBool(_kUseDummy) ?? _defaultUseDummy;
    final savedUrl = p.getString(_kBaseUrl);
    if (savedUrl != null && savedUrl.isNotEmpty) baseUrl.value = savedUrl;
  }

  static Future<void> setUseDummy(bool value) async {
    useDummy.value = value;
    await _prefs?.setBool(_kUseDummy, value);
  }

  static Future<void> setBaseUrl(String value) async {
    final v = value.trim().replaceAll(RegExp(r'/+$'), '');
    baseUrl.value = v.isEmpty ? _defaultBaseUrl : v;
    await _prefs?.setString(_kBaseUrl, baseUrl.value);
  }

  // -- Convenience reads used by the API layer -----------------------------

  static String get apiBaseUrl => baseUrl.value;
  static bool get useDummyData => useDummy.value;

  /// Bearer token attached to every outbound request. Set after login.
  static String? authToken;
}
