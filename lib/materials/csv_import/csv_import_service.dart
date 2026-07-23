import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';

class CsvImportResult {
  const CsvImportResult({
    required this.created,
    required this.updated,
    required this.invalidRows,
    required this.skippedRows,
    required this.saveFailures,
    this.quotaExceeded = false,
    this.quotaLimit,
  });

  final int created;
  final int updated;
  final List<CsvImportRow> invalidRows;
  final List<CsvImportRow> skippedRows;
  final List<CsvImportRow> saveFailures;
  final bool quotaExceeded;
  final int? quotaLimit;

  int get imported => created + updated;

  int get preValidatedFailures => invalidRows.length;
}

class CsvImportService {
  CsvImportService(this.ref);

  final Ref ref;

  Future<CsvImportResult> importRows(List<CsvImportRow> rows) async {
    final repo = ref.read(materialsRepositoryProvider);
    final policy = ref.read(premiumAccessPolicyProvider);
    final logger = ref.read(appLoggerProvider);

    final valid = rows.where((r) => r.errors.isEmpty).toList();
    final invalid = rows.where((r) => r.errors.isNotEmpty).toList();
    final existingIds = await repo.existingIds(
      valid.map((e) => e.sourceId).where((id) => id.isNotEmpty).toSet(),
    );
    final classified = valid.map((row) {
      if (row.sourceId.isNotEmpty && existingIds[row.sourceId] == true) {
        return row.kind == CsvImportRowKind.update
            ? row
            : CsvImportRow(
                lineNumber: row.lineNumber,
                kind: CsvImportRowKind.update,
                sourceId: row.sourceId,
                name: row.name,
                brand: row.brand,
                materialType: row.materialType,
                color: row.color,
                colorHex: row.colorHex,
                spoolWeight: row.spoolWeight,
                remainingWeight: row.remainingWeight,
                cost: row.cost,
                trackRemaining: row.trackRemaining,
                archived: row.archived,
                notes: row.notes,
                errors: row.errors,
              );
      }
      return CsvImportRow(
        lineNumber: row.lineNumber,
        kind: CsvImportRowKind.create,
        sourceId: row.sourceId,
        name: row.name,
        brand: row.brand,
        materialType: row.materialType,
        color: row.color,
        colorHex: row.colorHex,
        spoolWeight: row.spoolWeight,
        remainingWeight: row.remainingWeight,
        cost: row.cost,
        trackRemaining: row.trackRemaining,
        archived: row.archived,
        notes: row.notes,
        errors: row.errors,
      );
    }).toList();

    final creates = classified
        .where((r) => r.kind == CsvImportRowKind.create)
        .toList();
    final updates = classified
        .where((r) => r.kind == CsvImportRowKind.update)
        .toList();

    final limit = policy.materialLimit;
    if (limit != null && await repo.count() + creates.length > limit) {
      return CsvImportResult(
        created: 0,
        updated: 0,
        invalidRows: invalid,
        skippedRows: [],
        saveFailures: const [],
        quotaExceeded: true,
        quotaLimit: limit,
      );
    }

    if (!policy.stockTracking().allowed) {
      return CsvImportResult(
        created: 0,
        updated: 0,
        invalidRows: invalid,
        skippedRows: const [],
        saveFailures: const [],
        quotaExceeded: false,
        quotaLimit: limit,
      );
    }

    final result = await repo.upsertMaterials(
      creates: creates,
      updates: updates,
    );

    if (result.saveFailures.isNotEmpty) {
      for (final failure in result.saveFailures) {
        logger.error(
          AppLogCategory.db,
          'CSV import save failure',
          context: {'line': failure.lineNumber},
        );
      }
    }

    return CsvImportResult(
      created: result.created,
      updated: result.updated,
      invalidRows: invalid,
      skippedRows: result.skippedRows,
      saveFailures: result.saveFailures,
      quotaExceeded: false,
      quotaLimit: limit,
    );
  }
}

final csvImportServiceProvider = Provider<CsvImportService>((ref) {
  return CsvImportService(ref);
});
