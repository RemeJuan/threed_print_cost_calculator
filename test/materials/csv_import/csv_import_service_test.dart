import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_service.dart';
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
      'csv_import_service_${DateTime.now().microsecondsSinceEpoch}.db',
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

  ImportRow validRow(String name, {int line = 1}) {
    return ImportRow(
      lineNumber: line,
      name: name,
      brand: 'Brand',
      materialType: 'PLA',
      color: 'Black',
      colorHex: '',
      spoolWeight: 1000,
      remainingWeight: 950,
      cost: 24.99,
      notes: '',
      errors: const [],
    );
  }

  ImportRow invalidRow(String name, {int line = 1}) {
    return ImportRow(
      lineNumber: line,
      name: name,
      brand: '',
      materialType: '',
      color: '',
      colorHex: '',
      spoolWeight: 0,
      remainingWeight: 0,
      cost: 0,
      notes: '',
      errors: const ['Missing name', 'Missing color'],
    );
  }

  Future<void> expectMaterialCount(int expected) async {
    final records = await container
        .read(materialsRepositoryProvider)
        .getMaterials();
    expect(records.length, expected);
  }

  group('CsvImportService.importRows', () {
    test('imports valid rows', () async {
      final rows = [validRow('PLA Pro+', line: 1), validRow('PETG', line: 2)];

      final result = await container
          .read(csvImportServiceProvider)
          .importRows(rows);

      expect(result.imported, 2);
      expect(result.preValidatedFailures, 0);
      expect(result.saveFailures, isEmpty);
      await expectMaterialCount(2);
    });

    test(
      'returns zero imported when all rows have pre-validation failures',
      () async {
        final rows = [invalidRow('Bad Row', line: 1)];

        final result = await container
            .read(csvImportServiceProvider)
            .importRows(rows);

        expect(result.imported, 0);
        expect(result.preValidatedFailures, 1);
        expect(result.saveFailures, isEmpty);
        await expectMaterialCount(0);
      },
    );

    test('returns zero imported for empty list', () async {
      final result = await container
          .read(csvImportServiceProvider)
          .importRows([]);

      expect(result.imported, 0);
      expect(result.preValidatedFailures, 0);
      expect(result.saveFailures, isEmpty);
      await expectMaterialCount(0);
    });

    test('mixes valid and invalid rows', () async {
      final rows = [
        validRow('PLA Pro+', line: 1),
        invalidRow('Bad Row', line: 2),
        validRow('PETG', line: 3),
      ];

      final result = await container
          .read(csvImportServiceProvider)
          .importRows(rows);

      expect(result.imported, 2);
      expect(result.preValidatedFailures, 1);
      expect(result.saveFailures, isEmpty);
      await expectMaterialCount(2);
    });

    test(
      'sets autoDeductEnabled correctly based on remaining weight',
      () async {
        final fullyTrackedRow = ImportRow(
          lineNumber: 1,
          name: 'Tracked',
          brand: '',
          materialType: '',
          color: 'Black',
          colorHex: '',
          spoolWeight: 1000,
          remainingWeight: 900,
          cost: 24.99,
          notes: '',
          errors: const [],
        );

        final untrackedRow = ImportRow(
          lineNumber: 2,
          name: 'Untracked',
          brand: '',
          materialType: '',
          color: 'White',
          colorHex: '',
          spoolWeight: 1000,
          remainingWeight: 1000,
          cost: 24.99,
          notes: '',
          errors: const [],
        );

        await container.read(csvImportServiceProvider).importRows([
          fullyTrackedRow,
          untrackedRow,
        ]);

        final materials = await container
            .read(materialsRepositoryProvider)
            .getMaterials();
        final tracked = materials.firstWhere((m) => m.name == 'Tracked');
        final untracked = materials.firstWhere((m) => m.name == 'Untracked');
        expect(tracked.autoDeductEnabled, isTrue);
        expect(untracked.autoDeductEnabled, isFalse);
      },
    );
  });
}
