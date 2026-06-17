import 'dart:convert';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:auto_backup_platform/auto_backup_platform.dart';
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

class _FakeAutoBackupPlatform extends AutoBackupPlatform {
  bool pickDestinationCalled = false;
  bool writeBackupCalled = false;
  String? lastFileName;
  String? lastContents;

  @override
  Future<Map<String, dynamic>?> pickDestination() async {
    pickDestinationCalled = true;
    return {
      'accessToken': 'fake_token',
      'displayLabel': 'Backups',
      'platform': 'ios',
    };
  }

  @override
  Future<Map<String, dynamic>> writeBackup({
    required String accessToken,
    required String displayLabel,
    required String fileName,
    required String contents,
  }) async {
    writeBackupCalled = true;
    lastFileName = fileName;
    lastContents = contents;
    return {'ok': true};
  }
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
      printers: const [
        {'id': 'p1'},
      ],
      materials: const [],
      history: const [],
    );

    expect(payload['version'], 1);
    expect((payload['data'] as Map)['settings'], {'a': 1});
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

  test('exportBackup uses native folder picker on mobile platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final fakePlatform = _FakeAutoBackupPlatform();
    final container = await _container(
      extraOverrides: [
        autoBackupPlatformProvider.overrideWithValue(fakePlatform),
      ],
    );
    addTearDown(container.dispose);
    final service = container.read(backupRestoreServiceProvider);
    final db = container.read(databaseProvider);

    await StoreRef<String, Object?>.main()
        .record(DBName.settings.name)
        .put(db, GeneralSettingsModel.initial().toMap());

    final result = await service.exportBackup();

    expect(fakePlatform.pickDestinationCalled, true);
    expect(fakePlatform.writeBackupCalled, true);
    expect(
      fakePlatform.lastFileName,
      contains('3d_print_cost_calculator_backup_'),
    );
    expect(fakePlatform.lastContents, isNotEmpty);
    expect(result, isNotEmpty);
  });
}
