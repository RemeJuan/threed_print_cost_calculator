import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  final historyStore = StoreRef<Object?, Map<String, Object?>>(
    DBName.history.name,
  );

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

  test('updateRecord keeps history indexes in sync', () async {
    final dbHelpers = container.read(dbHelpersProvider(DBName.history));
    final printerIndex = PrinterIndexHelpers.fromContainer(container);
    final searchIndex = HistorySearchIndexHelpers.fromContainer(container);

    final key = await dbHelpers.insertRecord({
      'name': 'Old Benchy',
      'printer': 'Prusa MK4',
      'date': DateTime(2024, 1, 1).toIso8601String(),
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

    await container.read(historyPagedProvider.notifier).refreshIfNeeded();
    expect(container.read(historyPagedProvider).isStale, isFalse);

    await dbHelpers.updateRecord(resolvedKey, {
      'name': 'Updated Benchy',
      'printer': 'Bambu X1C',
    });

    expect(
      await printerIndex.getKeysMatchingPrinter('prusa'),
      isNot(contains(resolvedKey)),
    );
    expect(
      await printerIndex.getKeysMatchingPrinter('bambu'),
      contains(resolvedKey),
    );
    expect(
      await searchIndex.getKeysMatchingQuery('updated'),
      contains(resolvedKey),
    );
    expect(container.read(historyPagedProvider).isStale, isTrue);
  });

  test('getSettings falls back to a valid printer id when needed', () async {
    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    await printersStore.record('printer-1').put(db, {'name': 'Printer 1'});
    await printersStore.record('printer-2').put(db, {'name': 'Printer 2'});

    await StoreRef<String, Object?>.main()
        .record(DBName.settings.name)
        .put(db, {
          'electricityCost': '0.25',
          'wattage': '150',
          'activePrinter': 'missing-printer',
          'selectedMaterial': 'pla',
          'wearAndTear': '1.5',
          'failureRisk': '7.5',
          'labourRate': '22',
        });

    final settings = await container
        .read(dbHelpersProvider(DBName.settings))
        .getSettings();

    expect(settings.activePrinter, 'printer-1');
    expect(settings.electricityCost, '0.25');
  });

  test('getSettings returns initial values when nothing persisted', () async {
    final settings = await container
        .read(dbHelpersProvider(DBName.settings))
        .getSettings();

    expect(settings.activePrinter, '');
    expect(settings.selectedMaterial, '');
    expect(settings.electricityCost, '');
    expect(settings, isA<GeneralSettingsModel>());
  });

  test(
    'getSettings clears active printer when printer store is empty',
    () async {
      await StoreRef<String, Object?>.main()
          .record(DBName.settings.name)
          .put(db, {
            'electricityCost': '0.25',
            'wattage': '150',
            'activePrinter': 'printer-1',
            'selectedMaterial': 'pla',
            'wearAndTear': '1.5',
            'failureRisk': '7.5',
            'labourRate': '22',
          });

      final settings = await container
          .read(dbHelpersProvider(DBName.settings))
          .getSettings();

      expect(settings.activePrinter, '');
      expect(settings.electricityCost, '0.25');
    },
  );

  test('insertRecord marks paged history state stale', () async {
    final dbHelpers = container.read(dbHelpersProvider(DBName.history));
    final notifier = container.read(historyPagedProvider.notifier);

    await notifier.refreshIfNeeded();
    expect(container.read(historyPagedProvider).isStale, isFalse);

    await dbHelpers.insertRecord({
      'name': 'Newest Print',
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

    expect(container.read(historyPagedProvider).isStale, isTrue);
  });
}
