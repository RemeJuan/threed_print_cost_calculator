import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final calculatorPreferencesRepositoryProvider =
    Provider<CalculatorPreferencesRepository>(
      CalculatorPreferencesRepository.new,
    );

class CalculatorPreferencesRepository {
  CalculatorPreferencesRepository(this.ref);

  final Ref ref;

  Database get _db => ref.read(databaseProvider);

  StoreRef<String, Object?> get _store => StoreRef<String, Object?>.main();

  Future<String> getStringValue(String key) async {
    final raw = await _store.record(key).get(_db);
    final map = castDatabaseRecord(raw, storeName: 'main', key: key);
    if (map == null) return '';
    return map['value']?.toString() ?? '';
  }

  Future<void> saveStringValue(String key, String value) async {
    await _db.transaction((txn) async {
      final existing = await _store.record(key).getSnapshot(txn);
      if (existing == null) {
        await _store.record(key).add(txn, {'value': value});
      } else {
        await existing.ref.update(txn, {'value': value});
      }
    });
  }
}
