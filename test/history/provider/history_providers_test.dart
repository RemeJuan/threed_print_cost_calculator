import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/history/provider/history_providers.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  final store = stringMapStoreFactory.store('history');

  setUp(() async {
    final name = 'test_providers_${DateTime.now().microsecondsSinceEpoch}.db';
    db = await databaseFactoryMemory.openDatabase(name);

    // Add three records with different names/printers
    await store.add(db, {
      'name': 'Alpha',
      'totalCost': 1.0,
      'riskCost': 0.0,
      'filamentCost': 0.0,
      'electricityCost': 0.0,
      'labourCost': 0.0,
      'date': DateTime.now().toIso8601String(),
      'printer': 'Prusa',
      'material': 'PLA',
      'weight': 10,
      'timeHours': '01:00',
    });

    await store.add(db, {
      'name': 'Beta',
      'totalCost': 2.0,
      'riskCost': 0.0,
      'filamentCost': 0.0,
      'electricityCost': 0.0,
      'labourCost': 0.0,
      'date': DateTime.now().toIso8601String(),
      'printer': 'Ender',
      'material': 'PETG',
      'weight': 20,
      'timeHours': '02:00',
    });

    await store.add(db, {
      'name': 'Gamma',
      'totalCost': 3.0,
      'riskCost': 0.0,
      'filamentCost': 0.0,
      'electricityCost': 0.0,
      'labourCost': 0.0,
      'date': DateTime.now().toIso8601String(),
      'printer': 'Prusa Mini',
      'material': 'ABS',
      'weight': 30,
      'timeHours': '03:00',
    });

    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('returns all records when query is empty', () async {
    final records = await container.read(historyRecordsProvider.future);
    expect(records.length, 3);
  });

  test('filters by name and printer case-insensitive', () async {
    // filter by printer substring 'prusa'
    container.read(historyQueryProvider.notifier).setQuery('prusa');
    final prusaMatches = await container.read(historyRecordsProvider.future);
    expect(prusaMatches.length, 2);

    // filter by name 'beta'
    container.read(historyQueryProvider.notifier).setQuery('beta');
    final betaMatches = await container.read(historyRecordsProvider.future);
    expect(betaMatches.length, 1);
    final map = betaMatches.first.value as Map<String, dynamic>;
    expect(map['name'], 'Beta');
  });
}
