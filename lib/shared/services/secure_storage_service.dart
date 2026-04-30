import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

/// Encrypted storage for sensitive auth data.
/// Uses an in-memory cache so sync reads work identically to the old
/// GetStorage-based flow — the only difference is that data at rest is
/// encrypted via Android Keystore / iOS Keychain.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
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
    await _migrateFromGetStorage();
    for (final key in _sensitiveKeys) {
      _cache[key] = await _storage.read(key: key);
    }
  }

  /// One-time migration: move sensitive data from plaintext GetStorage
  /// into encrypted storage, then delete the insecure copies.
  Future<void> _migrateFromGetStorage() async {
    final alreadyMigrated =
        await _storage.read(key: '_migrated_to_secure') == 'true';
    if (alreadyMigrated) return;

    final box = GetStorage();
    for (final key in _sensitiveKeys) {
      final value = box.read<String>(key);
      if (value != null && value.isNotEmpty) {
        await _storage.write(key: key, value: value);
        await box.remove(key);
      }
    }
    await _storage.write(key: '_migrated_to_secure', value: 'true');
  }

  /// Sync read from memory cache.
  String? read(String key) => _cache[key];

  /// Update cache (sync) then persist to encrypted storage (async).
  Future<void> write(String key, String value) async {
    _cache[key] = value;
    await _storage.write(key: key, value: value);
  }

  /// Remove from cache (sync) then delete from encrypted storage (async).
  Future<void> remove(String key) async {
    _cache.remove(key);
    await _storage.delete(key: key);
  }
}
