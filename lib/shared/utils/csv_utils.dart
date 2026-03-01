import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

String _quote(Object? value) {
  final s = value?.toString() ?? '';
  final escaped = s.replaceAll('"', '""');
  return '"$escaped"';
}

String generateCsv(List<HistoryModel> items) {
  final buffer = StringBuffer();

  buffer.writeln(
    'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total',
  );

  for (final item in items) {
    final dateStr = item.date.toIso8601String();
    final electricity = (item.electricityCost).toString();
    final filament = (item.filamentCost).toString();
    final labour = (item.labourCost).toString();
    final risk = (item.riskCost).toString();
    final total = (item.totalCost).toString();

    final materialsFlattened = item.materialUsages
        .map((usage) {
          final name =
              usage['materialName']?.toString() ?? usage['materialId']?.toString() ?? 'Material';
          final weight = usage['weightGrams']?.toString() ?? '0';
          return '$name:${weight}g';
        })
        .join('; ');

    buffer.writeln(
      '${_quote(dateStr)},'
      '${_quote(item.printer)},'
      '${_quote(item.material)},'
      '${_quote(materialsFlattened)},'
      '${_quote(item.weight)},'
      '${_quote(item.timeHours)},'
      '${_quote(electricity)},'
      '${_quote(filament)},'
      '${_quote(labour)},'
      '${_quote(risk)},'
      '${_quote(total)}',
    );
  }

  return buffer.toString();
}

Future<String> writeCsvToFile(String csv) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/3d_print_history.csv');
  await file.writeAsString(csv);

  return file.path;
}

Future<void> exportCSVFile(List<HistoryModel> items) async {
  // Get the CSV file content
  final csv = generateCsv(items);
  final path = await writeCsvToFile(csv);

  await SharePlus.instance.share(
    ShareParams(files: [XFile(path)], text: '3D Print Cost History Export'),
  );
}

/// Range options for export
enum ExportRange { all, last7Days, last30Days }

/// Utility provider that can query history records and export CSVs.
class CsvUtils {
  final Ref ref;

  CsvUtils(this.ref);

  Database get _db => ref.read(databaseProvider);

  /// Instance wrapper for top-level generateCsv
  String generateCsvForItems(List<HistoryModel> items) => generateCsv(items);

  /// Instance wrapper for top-level writeCsvToFile
  Future<String> writeCsvFileToDisk(String csv) => writeCsvToFile(csv);

  /// Instance wrapper for top-level exportCSVFile
  Future<void> exportCsvForItems(List<HistoryModel> items) =>
      exportCSVFile(items);

  /// Query history records for the given [range], sorted by date descending.
  Future<List<HistoryModel>> queryHistory(
    ExportRange range, {
    DateTime? now,
  }) async {
    final store = stringMapStoreFactory.store('history');

    // We sort by date descending always
    final sortOrders = [SortOrder('date', false)];

    final referenceNow = (now ?? DateTime.now()).toUtc();

    // Always fetch records sorted by date descending; we apply range filtering in-memory
    final records = await store.find(
      _db,
      finder: Finder(sortOrders: sortOrders),
    );

    // If range is not all, apply in-memory date filtering to avoid Sembast
    // comparison quirks with string dates.
    List<RecordSnapshot> filtered = records;

    if (range != ExportRange.all) {
      final days = range == ExportRange.last7Days ? 7 : 30;
      final cutoff = referenceNow.subtract(Duration(days: days));
      filtered = records.where((r) {
        final map = r.value as Map<String, dynamic>;
        final dateVal = map['date'];
        try {
          final dt = dateVal is DateTime
              ? dateVal.toUtc()
              : DateTime.parse(dateVal.toString()).toUtc();
          return dt.isAtSameMomentAs(cutoff) || dt.isAfter(cutoff);
        } catch (_) {
          return false;
        }
      }).toList();
    }

    return filtered.map((r) {
      final map = r.value as Map<String, dynamic>;
      return HistoryModel.fromMap(map);
    }).toList();
  }

  /// Query and export history for the given [range].
  Future<void> exportForRange(ExportRange range) async {
    final items = await queryHistory(range);
    await exportCSVFile(items);
  }
}

final csvUtilsProvider = Provider<CsvUtils>((ref) => CsvUtils(ref));
