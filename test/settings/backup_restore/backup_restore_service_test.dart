import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_service.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

Future<ProviderContainer> _container({
  List<Override> extraOverrides = const [],
}) async {
  final db = await databaseFactoryMemory.openDatabase(
    'backup_restore_test_${_databaseCounter++}',
  );
  addTearDown(db.close);
  return ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      appLoggerProvider.overrideWithValue(
        const AppLogger(
          sink: _NoopLogSink(),
          config: AppLoggerConfig(minLevel: AppLogLevel.error),
        ),
      ),
      ...extraOverrides,
    ],
  );
}

int _databaseCounter = 0;

class _NoopLogSink extends AppLogSink {
  const _NoopLogSink();

  @override
  void log(AppLogEvent event) {}
}

void main() {
  test('exports backup json with expected payload', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);
    await StoreRef<String, Object?>.main()
        .record(DBName.settings.name)
        .put(
          db,
          const GeneralSettingsModel(
            electricityCost: '0.30',
            wattage: '200',
            activePrinter: 'p1',
            selectedMaterial: 'm1',
            wearAndTear: '0.10',
            failureRisk: '0.05',
            labourRate: '18',
          ).toMap(),
        );
    await stringMapStoreFactory
        .store(DBName.printers.name)
        .record('p1')
        .put(
          db,
          const PrinterModel(
            id: 'p1',
            name: 'Printer 1',
            bedSize: '220 x 220',
            wattage: '200',
            archived: false,
          ).toMap(),
        );
    await stringMapStoreFactory
        .store(DBName.materials.name)
        .record('m1')
        .put(
          db,
          const MaterialModel(
            id: 'm1',
            name: 'PLA',
            cost: '20',
            color: 'Red',
            weight: '1000',
            archived: false,
          ).toMap(),
        );
    await StoreRef<Object?, Map<String, Object?>>('history')
        .record('h1')
        .put(
          db,
          HistoryModel(
            name: 'Job 1',
            totalCost: 10,
            riskCost: 1,
            filamentCost: 5,
            electricityCost: 1,
            labourCost: 3,
            date: DateTime.utc(2026, 1, 1),
            printer: 'p1',
            material: 'm1',
            weight: 12,
            timeHours: '01:00',
          ).toMap(),
        );

    final jsonText = await service.exportBackupJson();
    final payload = jsonDecode(jsonText) as Map<String, dynamic>;

    expect(payload['version'], 1);
    expect(payload['schemaVersion'], 1);
    expect((payload['data']['printers'] as List).length, 1);
    expect((payload['data']['materials'] as List).length, 1);
    expect((payload['data']['history'] as List).length, 1);
  });

  test('builds shared backup payload shape', () {
    final payload = buildBackupPayload(
      settings: const {'a': 1},
      interfaceSettings: const {'showCurrency': true},
      printers: const [
        {'id': 'p1'},
      ],
      materials: const [],
      history: const [],
    );

    expect(payload['version'], 1);
    expect((payload['data'] as Map)['settings'], {'a': 1});
  });

  test('builds shared backup params with json filename override', () {
    final params = BackupRestoreService.buildBackupShareParams(
      '{"version":1}',
      'backup.json',
    );

    expect(params.fileNameOverrides, ['backup.json']);
    expect(params.files, hasLength(1));
    expect(params.files!.single.mimeType, backupJsonMimeType);
  });

  test('rejects invalid backup before restore', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);

    final db = container.read(databaseProvider);
    await stringMapStoreFactory
        .store(DBName.printers.name)
        .record('keep')
        .put(
          db,
          const PrinterModel(
            id: 'keep',
            name: 'Keep',
            bedSize: '220 x 220',
            wattage: '200',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.printers.name)
        .count(db);

    await expectLater(
      service.restoreBackupJson('{"version":2}'),
      throwsA(isA<FormatException>()),
    );
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      beforeCount,
    );
  });

  test('rejects restore when printer list contains non-map item', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.printers.name)
        .record('keep')
        .put(
          db,
          const PrinterModel(
            id: 'keep',
            name: 'Keep',
            bedSize: '220 x 220',
            wattage: '200',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.printers.name)
        .count(db);

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': ['not_a_map'],
        'materials': [],
        'history': [],
      },
    });

    await expectLater(
      service.restoreBackupJson(backup),
      throwsA(isA<FormatException>()),
    );
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      beforeCount,
    );
  });

  test('rejects restore when material list contains non-map item', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.materials.name)
        .record('keep')
        .put(
          db,
          const MaterialModel(
            id: 'keep',
            name: 'Keep',
            cost: '20',
            color: 'Red',
            weight: '1000',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.materials.name)
        .count(db);

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': [],
        'materials': ['not_a_map'],
        'history': [],
      },
    });

    await expectLater(
      service.restoreBackupJson(backup),
      throwsA(isA<FormatException>()),
    );
    expect(
      await stringMapStoreFactory.store(DBName.materials.name).count(db),
      beforeCount,
    );
  });

  test('rejects restore when printer is missing required id', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.printers.name)
        .record('keep')
        .put(
          db,
          const PrinterModel(
            id: 'keep',
            name: 'Keep',
            bedSize: '220 x 220',
            wattage: '200',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.printers.name)
        .count(db);

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': [
          {
            'name': 'No ID Printer',
            'bedSize': '220 x 220',
            'wattage': '200',
            'archived': false,
          },
        ],
        'materials': [],
        'history': [],
      },
    });

    await expectLater(
      service.restoreBackupJson(backup),
      throwsA(isA<FormatException>()),
    );
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      beforeCount,
    );
  });

  test('rejects restore when material has empty id', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.materials.name)
        .record('keep')
        .put(
          db,
          const MaterialModel(
            id: 'keep',
            name: 'Keep',
            cost: '20',
            color: 'Red',
            weight: '1000',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.materials.name)
        .count(db);

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': [],
        'materials': [
          {
            'id': '',
            'name': 'Empty ID Material',
            'cost': '20',
            'color': 'Red',
            'weight': '1000',
            'archived': false,
          },
        ],
        'history': [],
      },
    });

    await expectLater(
      service.restoreBackupJson(backup),
      throwsA(isA<FormatException>()),
    );
    expect(
      await stringMapStoreFactory.store(DBName.materials.name).count(db),
      beforeCount,
    );
  });

  test('rejects restore when history list contains non-map item', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.printers.name)
        .record('keep')
        .put(
          db,
          const PrinterModel(
            id: 'keep',
            name: 'Keep',
            bedSize: '220 x 220',
            wattage: '200',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.printers.name)
        .count(db);

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': [],
        'materials': [],
        'history': ['not_a_map'],
      },
    });

    await expectLater(
      service.restoreBackupJson(backup),
      throwsA(isA<FormatException>()),
    );
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      beforeCount,
    );
  });

  test('rejects restore when history contains duplicate ids', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.printers.name)
        .record('keep')
        .put(
          db,
          const PrinterModel(
            id: 'keep',
            name: 'Keep',
            bedSize: '220 x 220',
            wattage: '200',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.printers.name)
        .count(db);

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': [],
        'materials': [],
        'history': [
          {
            'id': 'dup',
            'name': 'Job 1',
            'totalCost': 10,
            'riskCost': 1,
            'filamentCost': 5,
            'electricityCost': 1,
            'labourCost': 3,
            'date': '2026-01-01T00:00:00.000Z',
            'printer': 'p1',
            'material': 'm1',
            'weight': 12,
            'timeHours': '01:00',
          },
          {
            'id': 'dup',
            'name': 'Job 2',
            'totalCost': 20,
            'riskCost': 2,
            'filamentCost': 10,
            'electricityCost': 2,
            'labourCost': 6,
            'date': '2026-01-02T00:00:00.000Z',
            'printer': 'p1',
            'material': 'm1',
            'weight': 24,
            'timeHours': '02:00',
          },
        ],
      },
    });

    await expectLater(
      service.restoreBackupJson(backup),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Duplicate history entry id'),
        ),
      ),
    );
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      beforeCount,
    );
  });

  test('rejects restore when printer list contains duplicate ids', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.printers.name)
        .record('keep')
        .put(
          db,
          const PrinterModel(
            id: 'keep',
            name: 'Keep',
            bedSize: '220 x 220',
            wattage: '200',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.printers.name)
        .count(db);

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': [
          {
            'id': 'printerA',
            'name': 'A',
            'bedSize': '220 x 220',
            'wattage': '200',
            'archived': false,
          },
          {
            'id': 'printerA',
            'name': 'A duplicate',
            'bedSize': '300 x 300',
            'wattage': '400',
            'archived': false,
          },
        ],
        'materials': [],
        'history': [],
      },
    });

    await expectLater(
      service.restoreBackupJson(backup),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Duplicate printer entry id'),
        ),
      ),
    );
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      beforeCount,
    );
  });

  test('rejects restore when material list contains duplicate ids', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.materials.name)
        .record('keep')
        .put(
          db,
          const MaterialModel(
            id: 'keep',
            name: 'Keep',
            cost: '30',
            color: '',
            weight: '0',
            materialType: 'PLA',
            archived: false,
          ).toMap(),
        );

    final beforeCount = await stringMapStoreFactory
        .store(DBName.materials.name)
        .count(db);

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': [],
        'materials': [
          {
            'id': 'matX',
            'name': 'X',
            'cost': '25',
            'color': '',
            'weight': '0',
            'materialType': 'PLA',
            'archived': false,
          },
          {
            'id': 'matX',
            'name': 'X duplicate',
            'cost': '30',
            'color': '',
            'weight': '0',
            'materialType': 'ABS',
            'archived': false,
          },
        ],
        'history': [],
      },
    });

    await expectLater(
      service.restoreBackupJson(backup),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Duplicate material entry id'),
        ),
      ),
    );
    expect(
      await stringMapStoreFactory.store(DBName.materials.name).count(db),
      beforeCount,
    );
  });

  test('restores backup by replacing existing local data', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await stringMapStoreFactory
        .store(DBName.printers.name)
        .record('old')
        .put(
          db,
          const PrinterModel(
            id: 'old',
            name: 'Old',
            bedSize: '220 x 220',
            wattage: '200',
            archived: false,
          ).toMap(),
        );

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': GeneralSettingsModel.initial().toMap(),
        'printers': [
          const PrinterModel(
            id: 'new',
            name: 'New',
            bedSize: '250 x 250',
            wattage: '300',
            archived: false,
          ).toMap()..['id'] = 'new',
        ],
        'materials': [],
        'history': [],
      },
    });

    await service.restoreBackupJson(backup);

    final printers = await stringMapStoreFactory
        .store(DBName.printers.name)
        .find(db);
    expect(printers, hasLength(1));
    expect(printers.single.key, 'new');
  });

  test('non-premium restore preserves current premium-only settings', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await StoreRef<String, Object?>.main()
        .record(DBName.settings.name)
        .put(
          db,
          const GeneralSettingsModel(
            electricityCost: '0.21',
            wattage: '180',
            averageWattage: '150',
            activePrinter: 'current_printer',
            selectedMaterial: 'current_material',
            wearAndTear: '0.11',
            failureRisk: '0.07',
            labourRate: '22',
            pricingMarkupPercent: '12',
            pricingSetupFee: '3.5',
            pricingRoundingMode: '.99',
            currencySymbol: 'USD',
            currencyPosition: 'after',
            currencySpacing: true,
          ).toMap(),
        );

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': const GeneralSettingsModel(
          electricityCost: '0.45',
          wattage: '260',
          averageWattage: '210',
          activePrinter: 'backup_printer',
          selectedMaterial: 'backup_material',
          wearAndTear: '0.40',
          failureRisk: '0.25',
          labourRate: '35',
          pricingMarkupPercent: '30',
          pricingSetupFee: '15',
          pricingRoundingMode: '.00',
          currencySymbol: 'EUR',
          currencyPosition: 'before',
          currencySpacing: false,
        ).toMap(),
        'printers': [],
        'materials': [],
        'history': [],
      },
    });

    final result = await service.restoreBackupJson(backup);
    final restored =
        await StoreRef<String, Object?>.main()
                .record(DBName.settings.name)
                .get(db)
            as Map<String, Object?>;
    final settings = GeneralSettingsModel.fromMap(restored);

    expect(result.skippedPremiumSettings, isTrue);
    expect(settings.electricityCost, '0.45');
    expect(settings.wattage, '260');
    expect(settings.averageWattage, '210');
    expect(settings.activePrinter, 'backup_printer');
    expect(settings.selectedMaterial, 'backup_material');
    expect(settings.wearAndTear, '0.11');
    expect(settings.failureRisk, '0.07');
    expect(settings.labourRate, '22');
    expect(settings.pricingMarkupPercent, '12');
    expect(settings.pricingSetupFee, '3.5');
    expect(settings.pricingRoundingMode, '.99');
    expect(settings.currencySymbol, 'USD');
    expect(settings.currencyPosition, 'after');
    expect(settings.currencySpacing, isTrue);
  });

  test('premium restore applies premium-only settings from backup', () async {
    final container = await _container(
      extraOverrides: [isPremiumProvider.overrideWithValue(true)],
    );
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await StoreRef<String, Object?>.main()
        .record(DBName.settings.name)
        .put(
          db,
          const GeneralSettingsModel(
            electricityCost: '0.21',
            wattage: '180',
            averageWattage: '150',
            activePrinter: 'current_printer',
            selectedMaterial: 'current_material',
            wearAndTear: '0.11',
            failureRisk: '0.07',
            labourRate: '22',
            pricingMarkupPercent: '12',
            pricingSetupFee: '3.5',
            pricingRoundingMode: '.99',
            currencySymbol: 'USD',
            currencyPosition: 'after',
            currencySpacing: true,
          ).toMap(),
        );

    final backup = jsonEncode({
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-01-01T00:00:00Z',
      'data': {
        'settings': const GeneralSettingsModel(
          electricityCost: '0.45',
          wattage: '260',
          averageWattage: '210',
          activePrinter: 'backup_printer',
          selectedMaterial: 'backup_material',
          wearAndTear: '0.40',
          failureRisk: '0.25',
          labourRate: '35',
          pricingMarkupPercent: '30',
          pricingSetupFee: '15',
          pricingRoundingMode: '.00',
          currencySymbol: 'EUR',
          currencyPosition: 'before',
          currencySpacing: false,
        ).toMap(),
        'printers': [],
        'materials': [],
        'history': [],
      },
    });

    final result = await service.restoreBackupJson(backup);
    final restored =
        await StoreRef<String, Object?>.main()
                .record(DBName.settings.name)
                .get(db)
            as Map<String, Object?>;
    final settings = GeneralSettingsModel.fromMap(restored);

    expect(result.skippedPremiumSettings, isFalse);
    expect(settings.electricityCost, '0.45');
    expect(settings.wearAndTear, '0.40');
    expect(settings.failureRisk, '0.25');
    expect(settings.labourRate, '35');
    expect(settings.pricingMarkupPercent, '30');
    expect(settings.pricingSetupFee, '15');
    expect(settings.pricingRoundingMode, '.00');
    expect(settings.currencySymbol, 'EUR');
    expect(settings.currencyPosition, 'before');
    expect(settings.currencySpacing, isFalse);
  });
}
