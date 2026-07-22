import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class _NoopLogSink extends AppLogSink {
  const _NoopLogSink();
  @override
  void log(AppLogEvent event) {}
}

void main() {
  test(
    'upsertMaterials updates known ids and creates new ids atomically',
    () async {
      final db = await databaseFactoryMemory.openDatabase(
        'materials_upsert_${DateTime.now().microsecondsSinceEpoch}.db',
      );
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
          appLoggerConfigProvider.overrideWithValue(
            const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(() async => db.close());

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
      final existing = (await repo.getMaterials()).single;

      final result = await repo.upsertMaterials(
        creates: [
          CsvImportRow(
            lineNumber: 2,
            kind: CsvImportRowKind.create,
            sourceId: 'foreign',
            name: 'New',
            brand: '',
            materialType: '',
            color: 'Blue',
            colorHex: '',
            spoolWeight: 500,
            remainingWeight: 500,
            cost: 5,
            trackRemaining: false,
            archived: false,
            notes: '',
            errors: const [],
          ),
        ],
        updates: [
          CsvImportRow(
            lineNumber: 3,
            kind: CsvImportRowKind.update,
            sourceId: existing.id,
            name: 'PLA updated',
            brand: '',
            materialType: '',
            color: 'Red',
            colorHex: '',
            spoolWeight: 2000,
            remainingWeight: 1500,
            cost: 15,
            trackRemaining: true,
            archived: true,
            notes: '',
            errors: const [],
          ),
        ],
      );

      expect(result.created, 1);
      expect(result.updated, 1);
      final materials = await repo.getMaterials();
      expect(materials, hasLength(2));
      expect((await repo.getMaterialById(existing.id))!.archived, isTrue);
      expect(materials.any((m) => m.name == 'New' && m.id.isNotEmpty), isTrue);
    },
  );

  test('upsertMaterials rolls back on repository failure', () async {
    final db = await databaseFactoryMemory.openDatabase(
      'materials_upsert_fail_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        appLoggerConfigProvider.overrideWithValue(
          const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(() async => db.close());

    final repo = container.read(materialsRepositoryProvider);
    await repo.saveMaterial(
      const MaterialModel(
        id: '',
        name: 'Seed',
        cost: '10',
        color: 'Black',
        weight: '1000',
        archived: false,
        autoDeductEnabled: false,
        originalWeight: 1000,
        remainingWeight: 1000,
      ),
    );
    final existing = (await repo.getMaterials()).single;

    var calls = 0;
    await expectLater(
      repo.upsertMaterials(
        updates: [
          CsvImportRow(
            lineNumber: 2,
            kind: CsvImportRowKind.update,
            sourceId: existing.id,
            name: 'Updated',
            brand: 'Brand',
            materialType: 'PLA',
            color: 'Red',
            colorHex: '#ff0000',
            spoolWeight: 2000,
            remainingWeight: 1500,
            cost: 15,
            trackRemaining: true,
            archived: true,
            notes: 'Notes',
            errors: const [],
          ),
        ],
        creates: [
          CsvImportRow(
            lineNumber: 3,
            kind: CsvImportRowKind.create,
            sourceId: 'new-id',
            name: 'New',
            brand: 'Brand',
            materialType: 'PLA',
            color: 'Blue',
            colorHex: '#0000ff',
            spoolWeight: 500,
            remainingWeight: 500,
            cost: 5,
            trackRemaining: false,
            archived: false,
            notes: 'Notes',
            errors: const [],
          ),
        ],
        onBeforeWrite: (row) async {
          calls += 1;
          if (calls == 2) {
            throw Exception('boom');
          }
        },
      ),
      throwsException,
    );

    final after = await repo.getMaterials();
    expect(after, hasLength(1));
    expect(after.single.id, existing.id);
    expect(after.single.name, 'Seed');
    expect(after.single.cost, '10');
    expect(after.single.archived, isFalse);
    expect(after.single.autoDeductEnabled, isFalse);
    expect(after.single.originalWeight, 1000);
    expect(after.single.remainingWeight, 1000);
  });
}
