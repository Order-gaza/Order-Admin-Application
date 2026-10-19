import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

/// Hybrid storage for sensitive auth data.
/// Uses memory cache for sync reads, FlutterSecureStorage for encrypted OS-level storage,
/// and GetStorage as a reliable persistent fallback across app restarts.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  // On web: FlutterSecureStorage uses localStorage (no platform options needed).
  // On Android: use encrypted shared preferences.
  // On iOS: use keychain with first_unlock accessibility.
  static final _storage = kIsWeb
      ? const FlutterSecureStorage()
      : const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions:
              IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  final Map<String, String?> _cache = {};

  /// All sensitive keys managed by this service.
  static const _sensitiveKeys = [
    'auth_token',
    'user_role',
    'user_id',
    'user_name',
    'user_email',
    'vendor_id',
    'vendor_name',
  ];

  /// Must be called once during app startup, before any reads.
  Future<void> init() async {
    final box = GetStorage();
    for (final key in _sensitiveKeys) {
      String? val;
      try {
        val = await _storage.read(key: key);
      } catch (e) {
        if (kDebugMode) debugPrint('[SecureStorage] Read error for $key: $e');
      }
      val ??= box.read<String>(key);
      _cache[key] = val;
    }
  }

  /// Sync read from memory cache.
  String? read(String key) => _cache[key];

  /// Update memory cache, encrypted storage, and persistent GetStorage fallback.
  Future<void> write(String key, String value) async {
    _cache[key] = value;
    final box = GetStorage();
    await box.write(key, value);
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) debugPrint('[SecureStorage] Write error for $key: $e');
    }
  }

  /// Remove from memory cache, encrypted storage, and persistent GetStorage fallback.
  Future<void> remove(String key) async {
    _cache.remove(key);
    final box = GetStorage();
    await box.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (e) {
      if (kDebugMode) debugPrint('[SecureStorage] Remove error for $key: $e');
    }
  }
}
