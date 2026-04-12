import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/services/material_stock_service.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
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
      'material_stock_service_${DateTime.now().microsecondsSinceEpoch}.db',
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

  HistoryModel buildHistory(List<Map<String, dynamic>> usages) {
    return HistoryModel(
      name: 'Saved print',
      totalCost: 1,
      riskCost: 0,
      filamentCost: 1,
      electricityCost: 0,
      labourCost: 0,
      date: DateTime.parse('2024-01-01T00:00:00.000Z'),
      printer: 'Printer',
      material: 'Material',
      weight: usages.fold<num>(
        0,
        (sum, usage) => sum + (usage['weightGrams'] as num),
      ),
      materialUsages: usages,
      timeHours: '00:10',
    );
  }

  test('deducts only tracked materials per usage row', () async {
    final repo = container.read(materialsRepositoryProvider);
    await stringMapStoreFactory
        .store('materials')
        .record('tracked')
        .put(
          db,
          const MaterialModel(
            id: 'tracked',
            name: 'PLA',
            cost: '20',
            color: 'Black',
            weight: '1000',
            archived: false,
            autoDeductEnabled: true,
            originalWeight: 1000,
            remainingWeight: 900,
          ).toMap(),
        );
    await stringMapStoreFactory
        .store('materials')
        .record('untracked')
        .put(
          db,
          const MaterialModel(
            id: 'untracked',
            name: 'ABS',
            cost: '22',
            color: 'White',
            weight: '1000',
            archived: false,
            originalWeight: 1000,
            remainingWeight: 1000,
          ).toMap(),
        );

    await container
        .read(materialStockServiceProvider)
        .deductForSavedHistory(
          buildHistory([
            {
              'materialId': 'tracked',
              'materialName': 'PLA',
              'costPerKg': 20,
              'weightGrams': 125,
            },
            {
              'materialId': 'untracked',
              'materialName': 'ABS',
              'costPerKg': 22,
              'weightGrams': 75,
            },
          ]),
        );

    expect((await repo.getMaterialById('tracked'))!.remainingWeight, 775);
    expect((await repo.getMaterialById('untracked'))!.remainingWeight, 1000);
  });

  test('deduction clamps at zero and repeated saves are cumulative', () async {
    final repo = container.read(materialsRepositoryProvider);
    await stringMapStoreFactory
        .store('materials')
        .record('tracked')
        .put(
          db,
          const MaterialModel(
            id: 'tracked',
            name: 'PLA',
            cost: '20',
            color: 'Black',
            weight: '1000',
            archived: false,
            autoDeductEnabled: true,
            originalWeight: 1000,
            remainingWeight: 150,
          ).toMap(),
        );

    final service = container.read(materialStockServiceProvider);

    await service.deductForSavedHistory(
      buildHistory([
        {
          'materialId': 'tracked',
          'materialName': 'PLA',
          'costPerKg': 20,
          'weightGrams': 80,
        },
      ]),
    );
    expect((await repo.getMaterialById('tracked'))!.remainingWeight, 70);

    await service.deductForSavedHistory(
      buildHistory([
        {
          'materialId': 'tracked',
          'materialName': 'PLA',
          'costPerKg': 20,
          'weightGrams': 120,
        },
      ]),
    );
    expect((await repo.getMaterialById('tracked'))!.remainingWeight, 0);
  });

  test('multiple usage rows for same material are summed once', () async {
    final repo = container.read(materialsRepositoryProvider);
    await stringMapStoreFactory
        .store('materials')
        .record('tracked')
        .put(
          db,
          const MaterialModel(
            id: 'tracked',
            name: 'PLA',
            cost: '20',
            color: 'Black',
            weight: '1000',
            archived: false,
            autoDeductEnabled: true,
            originalWeight: 1000,
            remainingWeight: 500,
          ).toMap(),
        );

    await container
        .read(materialStockServiceProvider)
        .deductForSavedHistory(
          buildHistory([
            {
              'materialId': 'tracked',
              'materialName': 'PLA',
              'costPerKg': 20,
              'weightGrams': 125,
            },
            {
              'materialId': 'tracked',
              'materialName': 'PLA',
              'costPerKg': 20,
              'weightGrams': 75,
            },
          ]),
        );

    expect((await repo.getMaterialById('tracked'))!.remainingWeight, 300);
  });
}
