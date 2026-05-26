import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  final store = StoreRef<Object?, Map<String, Object?>>('history');

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
    await store.record('legacy-string-key').put(db, {
      'name': 'Prusa Legacy',
      'printer': 'Prusa Mini',
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

    final byName = await helpers.getKeysMatchingQuery('prusa');
    final byPrinter = await helpers.getKeysMatchingQuery('mini');

    expect(byName.length, 2);
    expect(byPrinter.length, 2);
    expect(byName.toSet(), equals(byPrinter.toSet()));

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
    expect(keys.length, 2);

    final records = await store.find(db);
    expect(records.first.value[kHistorySearchTextField], isNotEmpty);
  });

  test('backfillSearchFields normalizes missing search fields', () async {
    final helperStore = StoreRef<Object?, Map<String, Object?>>('history');
    await helperStore.add(db, {
      'name': '  Gear -- Fix  ',
      'printer': 'MK4, Mini!',
      'date': DateTime.now().toIso8601String(),
    });

    final helpers = HistorySearchIndexHelpers.fromContainer(container);
    final updated = await helpers.backfillSearchFields();

    expect(updated, 4);

    final records = await helperStore.find(db);
    final normalized = records
        .firstWhere((record) => record.value['name'] == '  Gear -- Fix  ')
        .value;

    expect(normalized[kHistorySearchNameField], 'gear fix');
    expect(normalized[kHistorySearchPrinterField], 'mk4 mini');
    expect(normalized[kHistorySearchTextField], 'gear fix mk4 mini');
  });

  test('updateRecord and removeRecord keep index tokens in sync', () async {
    final helperStore = StoreRef<Object?, Map<String, Object?>>('history');
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

    await db.transaction((txn) async {
      await helpers.updateRecordInTransaction(
        txn: txn,
        oldName: 'Prusa Gear',
        oldPrinter: 'Prusa Mini',
        newName: 'Bambu Gear',
        newPrinter: 'Bambu X1',
        recordKey: key,
      );
    });

    expect(await helpers.getKeysMatchingQuery('bambu'), contains(key));

    await db.transaction((txn) async {
      await helpers.removeRecordInTransaction(
        txn: txn,
        name: 'Bambu Gear',
        printer: 'Bambu X1',
        recordKey: key,
      );
    });

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

  test('substring expansion is bounded per token length', () async {
    // Use distinct chars to trigger worst-case N*(N+1)/2 expansion
    // 20-char token → 20*21/2 = 210 substrings (not de-duped)
    final name = 'abcdefghijklmnopqrstuvwxyz123456'; // 32 distinct chars
    final key = await store.add(db, {
      'name': name,
      'printer': 'short',
      'date': DateTime.now().toIso8601String(),
    });

    final helpers = HistorySearchIndexHelpers.fromContainer(container);
    await helpers.backfillSearchFields();
    await helpers.rebuildIndex();

    final indexStore = stringMapStoreFactory.store('history_search_index');
    final allEntries = await indexStore.find(db);

    final recordEntries = allEntries.where(
      (entry) =>
          (entry.value['keys'] as List?)
              ?.map((k) => k.toString())
              .contains(key.toString()) ==
          true,
    );

    // 32-char token → 32*33/2 = 528 name substrings
    // "short" → 5*6/2 = 15 printer substrings
    // Total: 543 (some may merge with pre-existing entries)
    expect(recordEntries.length, equals(528 + 15));

    // Search with single char prefix still works
    final results = await helpers.getKeysMatchingQuery('a');
    expect(results, contains(key));
  });
}
