import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'premium_local_store_api.dart';

class CachedPremiumLocalStore implements PremiumLocalStore {
  CachedPremiumLocalStore(
    this._storage, {
    PremiumLocalStoreErrorHandler? onError,
    List<FlutterSecureStorage>? fallbackStorage,
  }) : _onError = onError,
       _fallbackStorage = fallbackStorage ?? const [];

  final FlutterSecureStorage _storage;
  final List<FlutterSecureStorage> _fallbackStorage;
  final PremiumLocalStoreErrorHandler? _onError;
  final Map<String, String> _cache = {};

  Future<void> preload() async {
    try {
      final values = await _storage.readAll();
      _cache
        ..clear()
        ..addAll(values);
    } catch (error, stackTrace) {
      _onError?.call(error, stackTrace);
    }
  }

  @override
  String? readSync(String key) => _cache[key];

  @override
  Future<String?> read(String key) async => _cache[key];

  @override
  Future<void> write(String key, String value) async {
    if (_cache[key] == value) {
      return;
    }

    try {
      await _writeToStorage(key, value);
      _cache[key] = value;
    } on PlatformException catch (error) {
      if (_isDuplicateKeychainItem(error)) {
        // Unresolvable keychain accessibility mismatch on iOS. The old item
        // was created with different keychain attributes than the current
        // FlutterSecureStorage configuration queries with. Its public
        // delete/read APIs cannot find items across accessibility boundaries,
        // so delete-then-retry cannot resolve every duplicate.
        //
        // Accept in-memory state for this session. It may be lost after app
        // restart, which is acceptable for these non-critical counters.
        _cache[key] = value;
        return;
      }
      _onError?.call(error, StackTrace.current);
    } catch (error, stackTrace) {
      _onError?.call(error, stackTrace);
    }
  }

  Future<void> _writeToStorage(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (error) {
      if (!_isDuplicateKeychainItem(error)) rethrow;
      // Item exists under different iOS keychain accessibility than what
      // _storage queries with. Try every known configuration before retrying.
      try {
        await _storage.delete(key: key);
      } catch (_) {}
      for (final fallback in _fallbackStorage) {
        try {
          await fallback.delete(key: key);
          break;
        } catch (_) {
          // Try the next fallback.
        }
      }
      await _storage.write(key: key, value: value);
    }
  }

  bool _isDuplicateKeychainItem(PlatformException error) =>
      error.code == '-25299';

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      _cache.remove(key);
    } catch (error, stackTrace) {
      _onError?.call(error, stackTrace);
    }
  }

  @override
  Future<Map<String, String>> readAll() async =>
      Map<String, String>.unmodifiable(_cache);
}
