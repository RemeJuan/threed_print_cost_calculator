import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef PremiumLocalStoreErrorHandler =
    void Function(Object error, StackTrace stackTrace);

abstract class PremiumLocalStore {
  String? readSync(String key);

  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<Map<String, String>> readAll();
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
  CachedPremiumLocalStore(this._storage, {PremiumLocalStoreErrorHandler? onError})
    : _onError = onError;

  final FlutterSecureStorage _storage;
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
    _cache[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (error, stackTrace) {
      _onError?.call(error, stackTrace);
    }
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
    try {
      await _storage.delete(key: key);
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
