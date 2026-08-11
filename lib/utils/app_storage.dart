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
  static const String _keyLanguageCode = 'language_code';

  static SharedPreferences? _prefs;

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

  static Future<void> saveAccessToken(String token) =>
      _instance.setString(_keyAccessToken, token);

  static String? getAccessToken() => _instance.getString(_keyAccessToken);

  static bool get isLoggedIn {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveRefreshToken(String token) =>
      _instance.setString(_keyRefreshToken, token);

  static String? getRefreshToken() => _instance.getString(_keyRefreshToken);

  static Future<void> saveCustomer(Map<String, dynamic> customer) =>
      _instance.setString(_keyCustomerData, jsonEncode(customer));

  static Map<String, dynamic>? getCustomer() {
    final raw = _instance.getString(_keyCustomerData);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> setOnboardingSeen() => _instance.setBool(_keyOnboardingSeen, true);

  static bool get hasSeenOnboarding => _instance.getBool(_keyOnboardingSeen) ?? false;

  static Future<void> saveLanguageCode(String code) => _instance.setString(_keyLanguageCode, code);

  static String getLanguageCode() => _instance.getString(_keyLanguageCode) ?? 'en';

  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    Map<String, dynamic>? customer,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    if (customer != null) await saveCustomer(customer);
  }

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

  static Future<void> clearAll() async {
    await _instance.clear();
  }
}