import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'premium_local_store_api.dart';

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
