import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'premium_local_store_keys.dart';

typedef PremiumLocalStoreErrorHandler =
    void Function(Object error, StackTrace stackTrace);

abstract class PremiumLocalStore {
  String? readSync(String key);

  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<Map<String, String>> readAll();
}

const _knownKeys = [
  testPremiumOverrideEnabledOnPreferenceKey,
  calculationCountPreferenceKey,
  completedCostingCountPreferenceKey,
  hasUsedGcodeImportPreferenceKey,
  cancelFeedbackPromptShownStatePreferenceKey,
  cancelFeedbackPromptSubmittedStatePreferenceKey,
  runCountPreferenceKey,
  paywallPreferenceKey,
];

class SharedPrefsPremiumLocalStore implements PremiumLocalStore {
  SharedPrefsPremiumLocalStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? readSync(String key) => _prefs.getString(key);

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    final result = <String, String>{};
    for (final key in _knownKeys) {
      final value = _prefs.getString(key);
      if (value != null) result[key] = value;
    }
    return Map<String, String>.unmodifiable(result);
  }
}

class SecurePremiumLocalStore implements PremiumLocalStore {
  SecurePremiumLocalStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  String? readSync(String key) {
    throw StateError('SecurePremiumLocalStore does not support sync reads');
  }

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

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
        // Unresolvable keychain accessibility mismatch on iOS.
        // The old item was created with different keychain attributes
        // than what the current FlutterSecureStorage queries with.
        // flush_secure_storage delete/read APIs cannot find items
        // across accessibility boundaries, so delete-then-retry
        // cannot work from the public API alone.
        //
        // Accept in-memory state: cache the value so readSync()
        // returns it for the current session. The value will be
        // lost on app restart, which for non-critical counters
        // like calculation count is acceptable.
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
      if (!_isDuplicateKeychainItem(error)) {
        rethrow;
      }

      // Item exists under different iOS keychain accessibility than what
      // _storage queries with. Delete it by trying every known config.
      try {
        await _storage.delete(key: key);
      } catch (_) {}
      for (final fallback in _fallbackStorage) {
        try {
          await fallback.delete(key: key);
          break;
        } catch (_) {
          // try next fallback
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

class InMemoryPremiumLocalStore implements PremiumLocalStore {
  InMemoryPremiumLocalStore([Map<String, String>? initialValues])
    : _values = {...?initialValues};

  final Map<String, String> _values;

  @override
  String? readSync(String key) => _values[key];

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async =>
      Map<String, String>.unmodifiable(_values);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
