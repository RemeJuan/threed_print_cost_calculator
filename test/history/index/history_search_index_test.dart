import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  final store = stringMapStoreFactory.store('history');

  setUp(() async {
    final name =
        'test_search_index_${DateTime.now().microsecondsSinceEpoch}.db';
    db = await databaseFactoryMemory.openDatabase(name);

    await store.add(db, {
      'name': 'Prusa Gear',
      'printer': 'Prusa Mini',
      'date': DateTime.now().toIso8601String(),
    });
    await store.add(db, {
      'name': 'Ender Bracket',
      'printer': 'Ender 3',
      'date': DateTime.now().toIso8601String(),
    });

    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('rebuildIndex supports name and printer lookups', () async {
    final helpers = HistorySearchIndexHelpers.fromContainer(container);
    await helpers.backfillSearchFields();
    await helpers.rebuildIndex();

    final byName = await helpers.getKeysMatchingQuery('gear');
    final byPrinter = await helpers.getKeysMatchingQuery('mini');

    expect(byName.length, 1);
    expect(byPrinter.length, 1);
    expect(byName.first, byPrinter.first);

    final records = await store.find(db);
    final indexed = records.firstWhere(
      (record) => record.value['name'] == 'Prusa Gear',
    );
    expect(indexed.value[kHistorySearchNameField], 'prusa gear');
    expect(indexed.value[kHistorySearchPrinterField], 'prusa mini');
  });

  test('query prefixes work without scanning history store', () async {
    final helpers = HistorySearchIndexHelpers.fromContainer(container);
    await helpers.backfillSearchFields();
    await helpers.rebuildIndex();

    final keys = await helpers.getKeysMatchingQuery('brac');
    expect(keys.length, 1);
  });

  test('getKeysMatchingQuery lazily rebuilds an empty index', () async {
    final helpers = HistorySearchIndexHelpers.fromContainer(container);
    final keys = await helpers.getKeysMatchingQuery('prusa');
    expect(keys.length, 1);

    final records = await store.find(db);
    expect(records.first.value[kHistorySearchTextField], isNotEmpty);
  });

  test('backfillSearchFields normalizes missing search fields', () async {
    final helperStore = stringMapStoreFactory.store('history');
    await helperStore.add(db, {
      'name': '  Gear -- Fix  ',
      'printer': 'MK4, Mini!',
      'date': DateTime.now().toIso8601String(),
    });

    final helpers = HistorySearchIndexHelpers.fromContainer(container);
    final updated = await helpers.backfillSearchFields();

    expect(updated, 3);

    final records = await helperStore.find(db);
    final normalized = records
        .firstWhere((record) => record.value['name'] == '  Gear -- Fix  ')
        .value;

    expect(normalized[kHistorySearchNameField], 'gear fix');
    expect(normalized[kHistorySearchPrinterField], 'mk4 mini');
    expect(normalized[kHistorySearchTextField], 'gear fix mk4 mini');
  });

  test('updateRecord and removeRecord keep index tokens in sync', () async {
    final helperStore = stringMapStoreFactory.store('history');
    final key = await helperStore.add(db, {
      'name': 'Prusa Gear',
      'printer': 'Prusa Mini',
      'date': DateTime.now().toIso8601String(),
    });

    final helpers = HistorySearchIndexHelpers.fromContainer(container);
    await helpers.backfillSearchFields();
    await helpers.rebuildIndex();

    expect(await helpers.getKeysMatchingQuery('gear'), contains(key));
    expect(await helpers.getKeysMatchingQuery('mini'), contains(key));

    await helpers.updateRecord(
      oldName: 'Prusa Gear',
      oldPrinter: 'Prusa Mini',
      newName: 'Bambu Gear',
      newPrinter: 'Bambu X1',
      recordKey: key,
    );

    expect(await helpers.getKeysMatchingQuery('bambu'), contains(key));

    await helpers.removeRecord(
      name: 'Bambu Gear',
      printer: 'Bambu X1',
      recordKey: key,
    );

    final indexRecords = await stringMapStoreFactory
        .store('history_search_index')
        .find(db);
    expect(
      indexRecords.every(
        (record) =>
            (record.value['keys'] as List?)
                ?.map((value) => value.toString())
                .contains(key.toString()) !=
            true,
      ),
      isTrue,
    );
  });
}
