import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class _NoopLogSink extends AppLogSink {
  const _NoopLogSink();

  @override
  void log(AppLogEvent event) {}
}

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'entity_repository_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        appLoggerConfigProvider.overrideWithValue(
          const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('materials repository inserts records', () async {
    final repo = container.read(materialsRepositoryProvider);

    final insertedKey = await repo.saveMaterial(
      const MaterialModel(
        id: '',
        name: 'PLA',
        cost: '25',
        color: 'Red',
        weight: '1000',
        archived: false,
      ),
    );

    expect(insertedKey, isNotNull);
    expect(await repo.getMaterials(), hasLength(1));
  });

  test('materials repository updates and deletes records', () async {
    final repo = container.read(materialsRepositoryProvider);
    await stringMapStoreFactory.store('materials').record('material-1').put(
      db,
      {
        'name': 'PLA',
        'cost': '25',
        'color': 'Red',
        'weight': '1000',
        'archived': false,
      },
    );

    await repo.saveMaterial(
      const MaterialModel(
        id: 'material-1',
        name: 'PETG',
        cost: '30',
        color: 'Blue',
        weight: '900',
        archived: false,
      ),
      id: 'material-1',
    );

    final material = await repo.getMaterialById('material-1');
    expect(material, isNotNull);
    expect(material!.name, 'PETG');
    expect(material.color, 'Blue');

    await repo.deleteMaterial('material-1');
    expect(await repo.getMaterialById('material-1'), isNull);
  });

  test('printers repository inserts records', () async {
    final repo = container.read(printersRepositoryProvider);

    final insertedKey = await repo.savePrinter(
      const PrinterModel(
        id: '',
        name: 'Prusa MK4',
        bedSize: '250x210',
        wattage: '120',
        archived: false,
      ),
    );

    expect(insertedKey, isNotNull);
    expect(await repo.getPrinters(), hasLength(1));
  });

  test('printers repository updates and deletes records', () async {
    final repo = container.read(printersRepositoryProvider);
    await stringMapStoreFactory.store('printers').record('printer-1').put(db, {
      'name': 'Prusa MK4',
      'bedSize': '250x210',
      'wattage': '120',
      'archived': false,
    });

    await repo.savePrinter(
      const PrinterModel(
        id: 'printer-1',
        name: 'Prusa XL',
        bedSize: '360x360',
        wattage: '150',
        archived: false,
      ),
      id: 'printer-1',
    );

    final printer = await repo.getPrinterById('printer-1');
    expect(printer, isNotNull);
    expect(printer!.name, 'Prusa XL');
    expect(printer.bedSize, '360x360');

    await repo.deletePrinter('printer-1');
    expect(await repo.getPrinterById('printer-1'), isNull);
  });
}
