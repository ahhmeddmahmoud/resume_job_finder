import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local storage service backed by [SharedPreferences].
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserUid = 'user_uid';
  static const String _keyCareerPreferences = 'career_preferences';
  static const String _keyLocaleCode = 'locale_code';
  static const String _keyThemeMode = 'theme_mode';

  bool get isOnboardingCompleted =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  Future<bool> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_keyOnboardingCompleted, value);

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  Future<bool> setLoggedIn(bool value) => _prefs.setBool(_keyIsLoggedIn, value);

  String? get userName => _prefs.getString(_keyUserName);

  Future<bool> setUserName(String value) =>
      _prefs.setString(_keyUserName, value);

  String? get userEmail => _prefs.getString(_keyUserEmail);
  String? get userUid => _prefs.getString(_keyUserUid);

  Future<bool> setUserEmail(String value) =>
      _prefs.setString(_keyUserEmail, value);

  Future<void> saveUserSession({
    required String name,
    required String email,
    String? uid,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserEmail, email);
    if (uid != null) await _prefs.setString(_keyUserUid, uid);
  }

  Future<void> clearUserSession() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserUid);
    await clearCareerPreferencesJson();
  }

  Map<String, dynamic>? getCareerPreferencesJson() {
    final raw = _prefs.getString(_keyCareerPreferences);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveCareerPreferencesJson(Map<String, dynamic> json) =>
      _prefs.setString(_keyCareerPreferences, jsonEncode(json));

  Future<bool> clearCareerPreferencesJson() =>
      _prefs.remove(_keyCareerPreferences);

  String get localeCode => _prefs.getString(_keyLocaleCode) ?? 'ar';

  Future<bool> setLocaleCode(String code) =>
      _prefs.setString(_keyLocaleCode, code);

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'light';

  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);
}
