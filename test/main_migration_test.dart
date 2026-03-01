import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/main.dart';

void main() {
  test('startup migration backfills materialUsages for old history records', () async {
    final db = await databaseFactoryMemory.openDatabase('migration_test.db');
    addTearDown(() => db.close());

    final historyStore = stringMapStoreFactory.store('history');
    final key = await historyStore.add(db, {
      'name': 'Legacy print',
      'material': 'PLA Black',
      'weight': 120,
      'totalCost': 10,
      'riskCost': 0,
      'filamentCost': 5,
      'electricityCost': 3,
      'labourCost': 2,
      'date': DateTime.now().toIso8601String(),
      'printer': 'Printer A',
      'timeHours': '01:00',
    });

    await startupMigration(db);

    final migrated = await historyStore.record(key).get(db) as Map<String, dynamic>;
    expect(migrated['materialUsages'], isA<List>());
    final usages = migrated['materialUsages'] as List;
    expect(usages.length, 1);
    expect((usages.first as Map)['materialName'], 'PLA Black');
    expect((usages.first as Map)['weightGrams'], 120);
  });
}
