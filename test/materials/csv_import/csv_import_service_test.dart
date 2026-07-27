import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_service.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_schema.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class _NoopLogSink extends AppLogSink {
  const _NoopLogSink();
  @override
  void log(AppLogEvent event) {}
}

class _LimitedPolicy extends DefaultPremiumAccessPolicy {
  _LimitedPolicy() : super(isPremium: false);
  @override
  int? get materialLimit => 1;
}

class _DeniedStockPolicy extends DefaultPremiumAccessPolicy {
  _DeniedStockPolicy() : super(isPremium: false);

  @override
  FeatureAccess stockTracking() => const FeatureAccess(
    allowed: false,
    feature: PremiumFeature.stockTracking,
  );
}

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'csv_import_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        appLoggerConfigProvider.overrideWithValue(
          const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  CsvImportRow row({
    required String id,
    required String name,
    required CsvImportRowKind kind,
    bool archived = false,
    bool trackRemaining = true,
    double spoolWeight = 1000,
    double remainingWeight = 900,
    double cost = 12.5,
  }) => CsvImportRow(
    lineNumber: 2,
    kind: kind,
    sourceId: id,
    name: name,
    brand: 'Brand',
    materialType: 'PLA',
    color: 'Red',
    colorHex: '#ff0000',
    spoolWeight: spoolWeight,
    remainingWeight: remainingWeight,
    cost: cost,
    trackRemaining: trackRemaining,
    archived: archived,
    notes: 'Notes',
    errors: const [],
  );

  test('classifies update create invalid', () async {
    final repo = container.read(materialsRepositoryProvider);
    await repo.saveMaterial(
      const MaterialModel(
        id: '',
        name: 'Existing',
        cost: '1',
        color: 'Black',
        weight: '100',
        archived: false,
      ),
    );
    final existing = await repo.getMaterials();
    final id = existing.single.id;
    final parser = const CsvImportParser();
    final file = parseCsvImportFile(
      '$materialsCsvHeader\n$id,Existing,Brand,PLA,Red,#ff0000,1000,900,12.5,true,false,Notes\n,New,Brand,PLA,Blue,#0000ff,1000,1000,12.5,false,true,Notes\n,Bad,Brand,PLA,Blue,#0000ff,0,1000,0,false,false,Notes\n',
    );
    final classified = parser.classify(file: file, existingIds: {id: true});
    expect(classified.rows[0].kind, CsvImportRowKind.update);
    expect(classified.rows[1].kind, CsvImportRowKind.create);
    expect(classified.rows[2].kind, CsvImportRowKind.invalid);
  });

  test(
    'create foreign ids gets local id and quota counts creates only',
    () async {
      final repo = container.read(materialsRepositoryProvider);
      final result = await container.read(csvImportServiceProvider).importRows([
        row(id: 'foreign-1', name: 'Create one', kind: CsvImportRowKind.create),
        row(id: '', name: 'Create two', kind: CsvImportRowKind.create),
      ]);

      expect(result.created, 2);
      expect(result.updated, 0);
      final materials = await repo.getMaterials();
      expect(materials, hasLength(2));
      expect(materials.every((m) => m.id.isNotEmpty), isTrue);
    },
  );

  test('known id full field update including archived and stock', () async {
    final repo = container.read(materialsRepositoryProvider);
    await repo.saveMaterial(
      const MaterialModel(
        id: '',
        name: 'PLA',
        cost: '10',
        color: 'Black',
        weight: '1000',
        archived: false,
        autoDeductEnabled: false,
        originalWeight: 1000,
        remainingWeight: 1000,
      ),
    );
    final material = (await repo.getMaterials()).single;
    final result = await container.read(csvImportServiceProvider).importRows([
      row(
        id: material.id,
        name: 'PLA updated',
        kind: CsvImportRowKind.update,
        archived: true,
        trackRemaining: false,
        spoolWeight: 2000,
        remainingWeight: 1500,
        cost: 15,
      ),
    ]);

    expect(result.updated, 1);
    final updated = await repo.getMaterialById(material.id);
    expect(updated!.name, 'PLA updated');
    expect(updated.archived, isTrue);
    expect(updated.autoDeductEnabled, isFalse);
    expect(updated.originalWeight, 2000);
    expect(updated.remainingWeight, 1500);
    expect(updated.cost, '15.0');
    expect(updated.color, 'Red');
    expect(updated.brand, 'Brand');
    expect(updated.materialType, 'PLA');
    expect(updated.colorHex, '#ff0000');
    expect(updated.notes, 'Notes');
  });

  test('denied stock tracking blocks persistence', () async {
    final deniedDb = await databaseFactoryMemory.openDatabase(
      'denied_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    final deniedContainer = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(deniedDb),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        appLoggerConfigProvider.overrideWithValue(
          const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
        premiumAccessPolicyProvider.overrideWithValue(_DeniedStockPolicy()),
      ],
    );
    addTearDown(deniedContainer.dispose);
    addTearDown(() async => deniedDb.close());

    final repo = deniedContainer.read(materialsRepositoryProvider);
    final result = await deniedContainer
        .read(csvImportServiceProvider)
        .importRows([
          row(id: 'new-id', name: 'Blocked', kind: CsvImportRowKind.create),
        ]);

    expect(result.created, 0);
    expect(result.updated, 0);
    expect(await repo.count(), 0);
  });

  test('quota applies only creates', () async {
    final quotaDb = await databaseFactoryMemory.openDatabase(
      'quota_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    final quotaContainer = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(quotaDb),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        appLoggerConfigProvider.overrideWithValue(
          const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
        premiumAccessPolicyProvider.overrideWithValue(_LimitedPolicy()),
      ],
    );
    addTearDown(quotaContainer.dispose);
    addTearDown(() async => quotaDb.close());
    final repo = quotaContainer.read(materialsRepositoryProvider);
    await repo.saveMaterial(
      const MaterialModel(
        id: '',
        name: 'Seed',
        cost: '1',
        color: 'Black',
        weight: '100',
        archived: false,
      ),
    );
    final seed = (await repo.getMaterials()).single;
    final result = await quotaContainer
        .read(csvImportServiceProvider)
        .importRows([
          row(id: seed.id, name: 'Seed updated', kind: CsvImportRowKind.update),
          row(id: 'new-id', name: 'New', kind: CsvImportRowKind.create),
        ]);
    expect(result.quotaExceeded, isTrue);
    expect(result.created, 0);
  });
}
