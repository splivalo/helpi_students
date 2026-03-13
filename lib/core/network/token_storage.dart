import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Pohranjuje JWT token i korisničke podatke u secure storage.
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'user_id';
  static const _keyUserType = 'user_type';

  // ── Write ─────────────────────────────────────
  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  static Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);

  static Future<void> saveUserType(String type) =>
      _storage.write(key: _keyUserType, value: type);

  // ── Read ──────────────────────────────────────
  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  static Future<String?> getUserId() => _storage.read(key: _keyUserId);

  static Future<String?> getUserType() => _storage.read(key: _keyUserType);

  // ── Delete ────────────────────────────────────
  static Future<void> clearAll() => _storage.deleteAll();
}
