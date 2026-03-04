import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  // Cast store to accept Object? keys so tests work with numeric keys returned by Sembast
  final historyStore =
      stringMapStoreFactory.store(DBName.history.name)
          as StoreRef<Object?, Map<String, Object?>>;

  setUp(() async {
    final name = 'test_db_helpers_${DateTime.now().microsecondsSinceEpoch}.db';
    db = await databaseFactoryMemory.openDatabase(name);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'deleteRecord removes history records keyed by int and updates index',
    () async {
      final dbHelpers = container.read(dbHelpersProvider(DBName.history));
      final key = await dbHelpers.insertRecord({
        'name': 'Delete Me',
        'printer': 'Prusa MK4',
        'date': DateTime.now().toUtc().toIso8601String(),
        'material': 'PLA',
        'weight': 25,
        'timeHours': '01:00',
        'totalCost': 2.0,
        'riskCost': 0.0,
        'filamentCost': 0.0,
        'electricityCost': 0.0,
        'labourCost': 0.0,
      });

      expect(key, isNotNull);
      final resolvedKey = key as Object;

      final indexHelpers = PrinterIndexHelpers.fromContainer(container);
      var keys = await indexHelpers.getKeysMatchingPrinter('prusa');
      expect(keys.contains(resolvedKey), isTrue);

      await dbHelpers.deleteRecord(resolvedKey);

      final deletedRecord = await historyStore.record(resolvedKey).get(db);
      expect(deletedRecord, isNull);

      keys = await indexHelpers.getKeysMatchingPrinter('prusa');
      expect(keys.contains(resolvedKey), isFalse);
    },
  );
}
