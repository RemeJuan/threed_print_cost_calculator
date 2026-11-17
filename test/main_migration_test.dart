import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/startup.dart';
import 'package:threed_print_cost_calculator/history/index/history_index_store_names.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  test(
    'v1 search migration rebuilds populated legacy postings to v2',
    () async {
      SharedPreferences.setMockInitialValues({
        historySearchRebuildMigrationKey: 1,
        printerIndexMigrationKey: 1,
        searchFieldBackfillMigrationKey: 1,
        legacyHistoryMigrationKey: 1,
      });
      final prefs = await SharedPreferences.getInstance();
      final db = await databaseFactoryMemory.openDatabase(
        'search_rebuild_v2.db',
      );
      addTearDown(() => db.close());
      final history = StoreRef<Object?, Map<String, Object?>>('history');
      await history.record(123).put(db, {'name': 'Typed Match', 'printer': ''});
      await history.record('123').put(db, {
        'name': 'Typed Match',
        'printer': '',
      });
      final oldIndex = stringMapStoreFactory.store(
        kHistorySearchIndexStoreName,
      );
      await oldIndex.record('searchName:typed').put(db, {
        'keys': ['123'],
      });
      expect(await oldIndex.count(db), greaterThan(0));

      await startupMigration(
        db,
        prefs: prefs,
        migrateLegacyHistoryRecordsFn: (_) async {},
        reportError: (_) {},
      );
      expect(
        prefs.getInt(historySearchRebuildMigrationKey),
        historySearchRebuildMigrationVersion,
      );
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final index = HistorySearchIndexHelpers.fromContainer(container);
      expect(await index.getKeysMatchingQuery('typed'), equals({123, '123'}));
      expect(
        await index.getKeysMatchingQuery('match'),
        containsAll([123, '123']),
      );
      await startupMigration(
        db,
        prefs: prefs,
        migrateLegacyHistoryRecordsFn: (_) async {},
        reportError: (_) {},
      );
      expect(
        await index.getKeysMatchingQuery('typed'),
        containsAll([123, '123']),
      );
    },
  );

  test(
    'v1 printer migration rebuilds populated legacy postings to v2',
    () async {
      SharedPreferences.setMockInitialValues({
        printerIndexMigrationKey: 1,
        searchFieldBackfillMigrationKey: searchFieldBackfillMigrationVersion,
        historySearchRebuildMigrationKey: historySearchRebuildMigrationVersion,
        legacyHistoryMigrationKey: legacyHistoryMigrationVersion,
      });
      final prefs = await SharedPreferences.getInstance();
      final db = await databaseFactoryMemory.openDatabase(
        'printer_rebuild_v2.db',
      );
      addTearDown(() => db.close());
      final history = StoreRef<Object?, Map<String, Object?>>('history');
      await history.record(123).put(db, {'printer': 'Mixed'});
      await history.record('123').put(db, {'printer': 'Mixed'});
      final oldIndex = stringMapStoreFactory.store(kPrinterIndexStoreName);
      await oldIndex.record('mixed').put(db, {
        'keys': ['123'],
      });

      await startupMigration(
        db,
        prefs: prefs,
        migrateLegacyHistoryRecordsFn: (_) async {},
        reportError: (_) {},
      );

      expect(
        prefs.getInt(printerIndexMigrationKey),
        printerIndexMigrationVersion,
      );
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final index = PrinterIndexHelpers.fromContainer(container);
      expect(
        await index.getKeysMatchingPrinter('mixed'),
        unorderedEquals([123, '123']),
      );
    },
  );

  test('migrates legacy history records into materialUsages', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
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

    await startupMigration(
      db,
      prefs: prefs,
      hooks: _FakeHooks([]),
      migrateLegacyHistoryRecordsFn: migrateLegacyHistoryRecords,
      reportError: (_) {},
    );

    final migrated =
        await historyStore.record(key).get(db) as Map<String, dynamic>;
    expect(migrated['materialUsages'], isA<List>());
    final usages = migrated['materialUsages'] as List;
    expect(usages.length, 1);
    expect((usages.first as Map)['materialName'], 'PLA Black');
    expect((usages.first as Map)['weightGrams'], 120);
  });

  test('migrates legacy history records with string weight', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase('migration_string.db');
    addTearDown(() => db.close());

    final historyStore = stringMapStoreFactory.store('history');
    final key = await historyStore.add(db, {
      'name': 'Legacy string print',
      'materialId': 'mat-1',
      'weight': '120',
      'source': 'Imported',
      'printer': 'Printer A',
      'keepMe': 'yes',
    });

    await startupMigration(
      db,
      prefs: prefs,
      hooks: _FakeHooks([]),
      migrateLegacyHistoryRecordsFn: migrateLegacyHistoryRecords,
      reportError: (_) {},
    );

    final migrated =
        await historyStore.record(key).get(db) as Map<String, dynamic>;
    expect(migrated['keepMe'], 'yes');
    final usages = migrated['materialUsages'] as List;
    expect((usages.first as Map)['materialId'], 'mat-1');
    expect((usages.first as Map)['materialName'], kUnassignedLabel);
    expect((usages.first as Map)['costPerKg'], 0);
    expect((usages.first as Map)['weightGrams'], 120);
  });

  test('skips records that already have materialUsages', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase('migration_skip.db');
    addTearDown(() => db.close());

    final historyStore = stringMapStoreFactory.store('history');
    final key = await historyStore.add(db, {
      'name': 'Existing print',
      'materialUsages': [
        {
          'materialId': 'mat-1',
          'materialName': 'PETG',
          'costPerKg': 20,
          'weightGrams': 50,
        },
      ],
      'weight': 50,
      'printer': 'Printer A',
    });

    await startupMigration(
      db,
      prefs: prefs,
      hooks: _FakeHooks([]),
      migrateLegacyHistoryRecordsFn: migrateLegacyHistoryRecords,
      reportError: (_) {},
    );

    final migrated =
        await historyStore.record(key).get(db) as Map<String, dynamic>;
    expect(migrated['materialUsages'], hasLength(1));
    expect(
      (migrated['materialUsages'] as List).first,
      containsPair('materialName', 'PETG'),
    );
  });

  test('handles partial legacy fields safely', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase('migration_partial.db');
    addTearDown(() => db.close());

    final historyStore = stringMapStoreFactory.store('history');
    final key = await historyStore.add(db, {
      'name': 'Partial print',
      'printer': 'Printer A',
    });

    await startupMigration(
      db,
      prefs: prefs,
      hooks: _FakeHooks([]),
      migrateLegacyHistoryRecordsFn: migrateLegacyHistoryRecords,
      reportError: (_) {},
    );

    final migrated =
        await historyStore.record(key).get(db) as Map<String, dynamic>;
    final usages = migrated['materialUsages'] as List;
    expect((usages.first as Map)['materialId'], '');
    expect((usages.first as Map)['materialName'], kUnassignedLabel);
    expect((usages.first as Map)['weightGrams'], 0);
  });

  test(
    'migrates legacy records without overwriting concurrent edits',
    () async {
      final db = await databaseFactoryMemory.openDatabase(
        'migration_concurrent.db',
      );
      addTearDown(() => db.close());

      final historyStore = stringMapStoreFactory.store('history');
      for (var i = 0; i < legacyHistoryMigrationBatchSize; i++) {
        await historyStore.add(db, {
          'name': 'Seed $i',
          'material': 'PLA',
          'weight': 10,
        });
      }

      final targetKey = await historyStore.add(db, {
        'name': 'Legacy target',
        'material': 'Old Material',
        'weight': 40,
        'keepMe': 'before',
      });

      final migrationFuture = migrateLegacyHistoryRecords(db);

      await historyStore.record(targetKey).put(db, {
        'name': 'Legacy target',
        'material': 'New Material',
        'weight': 75,
        'keepMe': 'after',
      });

      await migrationFuture;

      final migrated =
          await historyStore.record(targetKey).get(db) as Map<String, dynamic>;
      expect(migrated['keepMe'], 'after');
      final usages = migrated['materialUsages'] as List;
      expect((usages.first as Map)['materialName'], 'New Material');
      expect((usages.first as Map)['weightGrams'], 75);
    },
  );

  test('runs startup tasks in order', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase('startup_sequence.db');
    addTearDown(() => db.close());

    final calls = <String>[];
    await startupMigration(
      db,
      prefs: prefs,
      hooks: _FakeHooks(calls),
      migrateLegacyHistoryRecordsFn: (_) async {
        calls.add('migrate');
      },
      reportError: (_) {},
    );

    expect(calls, ['printer', 'search_backfill', 'search_rebuild', 'migrate']);
  });

  test('yields before starting scheduled startup migrations', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase('startup_yield.db');
    addTearDown(() => db.close());

    final calls = <String>[];
    unawaited(
      startupMigration(
        db,
        prefs: prefs,
        hooks: _FakeHooks(calls),
        migrateLegacyHistoryRecordsFn: (_) async {
          calls.add('migrate');
        },
        reportError: (_) {},
      ),
    );

    expect(calls, isEmpty);
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['printer']);
  });

  test('reports and rethrows startup failures', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase('startup_error.db');
    addTearDown(() => db.close());

    final reported = <FlutterErrorDetails>[];
    late final Object thrown;
    late final StackTrace thrownStack;

    try {
      await startupMigration(
        db,
        prefs: prefs,
        hooks: _ThrowingHooks(),
        reportError: reported.add,
      );
      fail('Expected startupMigration to throw');
    } catch (error, stack) {
      thrown = error;
      thrownStack = stack;
      expect(error, isStateError);
    }

    expect(reported, hasLength(1));
    expect(
      prefs.getInt(printerIndexMigrationKey),
      printerIndexMigrationVersion,
    );
    expect(prefs.getInt(searchFieldBackfillMigrationKey), isNull);
    expect(prefs.getInt(historySearchRebuildMigrationKey), isNull);
    expect(prefs.getInt(legacyHistoryMigrationKey), isNull);
    expect(reported.single.library, 'startupMigration');
    expect(
      reported.single.context.toString(),
      'History search/printer index rebuild / migration',
    );
    expect(reported.single.stack, isNotNull);
    expect(reported.single.stack, same(thrownStack));
    expect(reported.single.exception, isA<StateError>());
    expect(reported.single.exception, same(thrown));
  });

  test('skips completed migration versions', () async {
    SharedPreferences.setMockInitialValues({
      printerIndexMigrationKey: printerIndexMigrationVersion,
      searchFieldBackfillMigrationKey: searchFieldBackfillMigrationVersion,
      historySearchRebuildMigrationKey: historySearchRebuildMigrationVersion,
      legacyHistoryMigrationKey: legacyHistoryMigrationVersion,
    });
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase('startup_version.db');
    addTearDown(() => db.close());

    final calls = <String>[];
    await startupMigration(
      db,
      prefs: prefs,
      hooks: _FakeHooks(calls),
      migrateLegacyHistoryRecordsFn: (_) async {
        calls.add('migrate');
      },
      reportError: (_) {},
    );

    expect(calls, isEmpty);
  });

  testWidgets('schedules deferred startup migration after first frame', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase('startup_deferred.db');
    addTearDown(() => db.close());

    final calls = <String>[];
    scheduleDeferredStartupMigration(
      db: db,
      prefs: prefs,
      hooks: _FakeHooks(calls),
      migrateLegacyHistoryRecordsFn: (_) async {
        calls.add('migrate');
      },
      reportError: (_) {},
    );

    expect(calls, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));

    expect(calls, ['printer', 'search_backfill', 'search_rebuild', 'migrate']);
  });
}

class _FakeHooks implements StartupMigrationHooks {
  _FakeHooks(this.calls);

  final List<String> calls;

  @override
  Future<void> backfillSearchFields() async {
    calls.add('search_backfill');
  }

  @override
  Future<void> rebuildHistorySearchIndex() async {
    calls.add('search_rebuild');
  }

  @override
  Future<void> rebuildPrinterIndex() async {
    calls.add('printer');
  }
}

class _ThrowingHooks implements StartupMigrationHooks {
  @override
  Future<void> backfillSearchFields() async {
    throw StateError('boom');
  }

  @override
  Future<void> rebuildHistorySearchIndex() async {}

  @override
  Future<void> rebuildPrinterIndex() async {}
}
