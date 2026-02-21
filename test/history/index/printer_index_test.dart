import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  final store = stringMapStoreFactory.store('history');

  setUp(() async {
    final name = 'test_index_${DateTime.now().microsecondsSinceEpoch}.db';
    db = await databaseFactoryMemory.openDatabase(name);

    await store.add(db, {
      'name': 'A',
      'printer': 'Prusa',
      'date': DateTime.now().toIso8601String(),
    });
    await store.add(db, {
      'name': 'B',
      'printer': 'Prusa Mini',
      'date': DateTime.now().toIso8601String(),
    });
    await store.add(db, {
      'name': 'C',
      'printer': 'Ender',
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

  test('rebuildIndex creates entries for printers', () async {
    final helpers = PrinterIndexHelpers.fromContainer(container);
    await helpers.rebuildIndex();

    final printers = await helpers.getAllIndexedPrinters();
    expect(printers.contains('prusa'), isTrue);
    expect(printers.contains('prusa mini'), isTrue);
    expect(printers.contains('ender'), isTrue);
  });

  test('getKeysMatchingPrinter returns correct keys', () async {
    final helpers = PrinterIndexHelpers.fromContainer(container);
    await helpers.rebuildIndex();

    final keys = await helpers.getKeysMatchingPrinter('prusa');
    // Should find both 'prusa' and 'prusa mini' entries -> at least 2 keys
    expect(keys.length, 2);
  });

  test('addKey and removeKey update index', () async {
    final helpers = PrinterIndexHelpers.fromContainer(container);
    await helpers.rebuildIndex();

    // add a new record key for 'Prusa'
    await helpers.addKey('Prusa', 'customKey');
    var keys = await helpers.getKeysMatchingPrinter('prusa');
    expect(keys.contains('customKey'), isTrue);

    // remove it
    await helpers.removeKey('Prusa', 'customKey');
    keys = await helpers.getKeysMatchingPrinter('prusa');
    expect(keys.contains('customKey'), isFalse);
  });
}
