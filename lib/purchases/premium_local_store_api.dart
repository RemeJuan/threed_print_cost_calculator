typedef PremiumLocalStoreErrorHandler =
    void Function(Object error, StackTrace stackTrace);

abstract class PremiumLocalStore {
  String? readSync(String key);

  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<Map<String, String>> readAll();
}
