import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/super_admin_user.dart';

class StorageService {
  static const _keyToken = 'super_admin_token';
  static const _keyUser = 'super_admin_user';
  static const _keyBaseUrl = 'api_base_url';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveBaseUrl(String url) async {
    await init();
    await _prefs?.setString(_keyBaseUrl, url.trim());
  }

  Future<String?> getBaseUrl() async {
    await init();
    return _prefs?.getString(_keyBaseUrl);
  }

  Future<void> saveToken(String token) async {
    await init();
    await _prefs?.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    await init();
    return _prefs?.getString(_keyToken);
  }

  Future<void> saveUser(SuperAdminUser user) async {
    await init();
    await _prefs?.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<SuperAdminUser?> getUser() async {
    await init();
    final raw = _prefs?.getString(_keyUser);
    if (raw == null) return null;
    try {
      return SuperAdminUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuthSession() async {
    await init();
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUser);
  }
}
