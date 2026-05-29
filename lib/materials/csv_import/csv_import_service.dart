import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class CsvImportResult {
  final int imported;
  final int preValidatedFailures;
  final List<ImportRow> saveFailures;
  final bool quotaExceeded;
  final int? quotaLimit;

  const CsvImportResult({
    required this.imported,
    required this.preValidatedFailures,
    required this.saveFailures,
    this.quotaExceeded = false,
    this.quotaLimit,
  });
}

class CsvImportService {
  CsvImportService(this.ref);
  final Ref ref;

  Future<CsvImportResult> importRows(List<ImportRow> rows) async {
    final valid = rows.where((r) => r.errors.isEmpty).toList();
    final preValidatedFailures = rows.length - valid.length;
    if (valid.isEmpty) {
      return CsvImportResult(
        imported: 0,
        preValidatedFailures: preValidatedFailures,
        saveFailures: [],
      );
    }

    final repo = ref.read(materialsRepositoryProvider);
    final logger = ref.read(appLoggerProvider);
    final policy = ref.read(premiumAccessPolicyProvider);
    final currentCount = await repo.count();
    final limit = policy.materialLimit;
    if (limit != null && currentCount + valid.length > limit) {
      return CsvImportResult(
        imported: 0,
        preValidatedFailures: preValidatedFailures,
        saveFailures: [],
        quotaExceeded: true,
        quotaLimit: limit,
      );
    }

    var imported = 0;
    final failedRows = <ImportRow>[];

    for (final row in valid) {
      final material = MaterialModel(
        id: '',
        name: row.name,
        cost: row.cost.toString(),
        color: row.color,
        weight: row.spoolWeight.toString(),
        archived: false,
        autoDeductEnabled:
            row.remainingWeight > 0 && row.remainingWeight != row.spoolWeight,
        originalWeight: row.spoolWeight,
        remainingWeight: row.remainingWeight,
        brand: row.brand,
        materialType: row.materialType,
        colorHex: row.colorHex,
        notes: row.notes,
      );
      try {
        await repo.saveMaterial(material);
        imported++;
      } catch (error, stackTrace) {
        failedRows.add(row);
        logger.error(
          AppLogCategory.db,
          'CSV import failed for row ${row.lineNumber} (name: ${row.name})',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return CsvImportResult(
      imported: imported,
      preValidatedFailures: preValidatedFailures,
      saveFailures: failedRows,
    );
  }
}

final csvImportServiceProvider = Provider<CsvImportService>((ref) {
  return CsvImportService(ref);
});
