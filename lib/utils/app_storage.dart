import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Shopzo — centralized local storage for auth/session data.
///
/// Stores accessToken + refreshToken SEPARATELY (API returns both — access
/// token is short-lived, refresh token is used by NetworkApiServices to
/// silently get a new access token when the old one expires, so the user
/// never has to log in again unless the refresh token itself is invalid).
class AppStorage {
  AppStorage._();

  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _keyCustomerData = 'customer_data';
  static const String _keyOnboardingSeen = 'onboarding_seen';

  static SharedPreferences? _prefs;

  /// Call once in main() BEFORE runApp(), so Splash can safely check
  /// AppStorage.isLoggedIn on first frame without any async gap/flicker.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError(
        'AppStorage not initialized. Call AppStorage.init() in main() before runApp().',
      );
    }
    return _prefs!;
  }

  // ---------------------------------------------------------------------
  // ACCESS TOKEN
  // ---------------------------------------------------------------------
  static Future<void> saveAccessToken(String token) =>
      _instance.setString(_keyAccessToken, token);

  static String? getAccessToken() => _instance.getString(_keyAccessToken);

  /// Logged-in state is derived from access token presence — single source
  /// of truth, no separate "is_logged_in" flag to fall out of sync.
  static bool get isLoggedIn {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ---------------------------------------------------------------------
  // REFRESH TOKEN
  // ---------------------------------------------------------------------
  static Future<void> saveRefreshToken(String token) =>
      _instance.setString(_keyRefreshToken, token);

  static String? getRefreshToken() => _instance.getString(_keyRefreshToken);

  // ---------------------------------------------------------------------
  // CUSTOMER DATA (raw JSON, so any extra fields survive without new methods)
  // ---------------------------------------------------------------------
  static Future<void> saveCustomer(Map<String, dynamic> customer) =>
      _instance.setString(_keyCustomerData, jsonEncode(customer));

  static Map<String, dynamic>? getCustomer() {
    final raw = _instance.getString(_keyCustomerData);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }


  static Future<void> setOnboardingSeen() => _instance.setBool(_keyOnboardingSeen, true);

  static bool get hasSeenOnboarding => _instance.getBool(_keyOnboardingSeen) ?? false;


  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    Map<String, dynamic>? customer,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    if (customer != null) await saveCustomer(customer);
  }

  /// Called internally by NetworkApiServices after a silent token refresh.
  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }



  static Future<void> logout() async {
    await _instance.remove(_keyAccessToken);
    await _instance.remove(_keyRefreshToken);
    await _instance.remove(_keyCustomerData);
    await _instance.remove(_keyOnboardingSeen);
  }

  /// Full wipe — rarely needed (e.g. a debug "clear app data" action).
  static Future<void> clearAll() async {
    await _instance.clear();
  }
}