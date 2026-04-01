import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

String _quote(Object? value) {
  final s = value?.toString() ?? '';
  final escaped = s.replaceAll('"', '""');
  return '"$escaped"';
}

String _sanitizeForCsv(String input) {
  if (input.isEmpty) return input;
  // Find the first non-whitespace/control character (chars with codeUnit > 0x20)
  int firstIndex = 0;
  while (firstIndex < input.length) {
    final cu = input.codeUnitAt(firstIndex);
    if (cu > 0x20) break;
    firstIndex++;
  }

  if (firstIndex >= input.length) return input; // all whitespace/control

  final firstChar = input[firstIndex];
  if (firstChar == '=' ||
      firstChar == '+' ||
      firstChar == '-' ||
      firstChar == '@') {
    // Prefix with a single quote but keep leading whitespace/control characters intact
    return "'$input";
  }

  return input;
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
          final rawName =
              usage['materialName']?.toString() ??
              usage['materialId']?.toString() ??
              'Material';
          final name = _sanitizeForCsv(rawName);
          final weight = _sanitizeForCsv(
            usage['weightGrams']?.toString() ?? '0',
          );
          return '$name:${weight}g';
        })
        .join('; ');

    buffer.writeln(
      '${_quote(_sanitizeForCsv(dateStr))},'
      '${_quote(_sanitizeForCsv(item.printer))},'
      '${_quote(_sanitizeForCsv(item.material))},'
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
    final referenceNow = (now ?? DateTime.now()).toUtc();
    var items = await ref.read(historyRepositoryProvider).getAllHistory();

    if (range != ExportRange.all) {
      final days = range == ExportRange.last7Days ? 7 : 30;
      final cutoff = referenceNow.subtract(Duration(days: days));
      items = items.where((entry) {
        final dt = entry.model.date.toUtc();
        return dt.isAtSameMomentAs(cutoff) || dt.isAfter(cutoff);
      }).toList();
    }

    return items.map((entry) => entry.model).toList();
  }

  /// Query and export history for the given [range].
  Future<void> exportForRange(ExportRange range) async {
    final items = await queryHistory(range);
    await exportCSVFile(items);
  }
}

final csvUtilsProvider = Provider<CsvUtils>((ref) => CsvUtils(ref));
