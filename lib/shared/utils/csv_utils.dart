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

String generateCsv(List<HistoryModel> items, String csvHeader) {
  final buffer = StringBuffer();

  buffer.writeln(csvHeader);

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

List<HistoryModel> buildSampleHistoryItems() {
  return [
    HistoryModel(
      name: 'Sample Benchy',
      totalCost: 18.9,
      riskCost: 1.5,
      filamentCost: 9.8,
      electricityCost: 2.1,
      labourCost: 5.5,
      date: DateTime.utc(2026, 4, 12, 9, 0),
      printer: 'Bambu Lab A1',
      material: 'PLA',
      weight: 87,
      materialUsages: const [
        {'materialName': 'PLA Matte White', 'weightGrams': 87},
      ],
      timeHours: '03:40',
    ),
    HistoryModel(
      name: 'Sample Bracket',
      totalCost: 26.35,
      riskCost: 2.0,
      filamentCost: 13.15,
      electricityCost: 2.7,
      labourCost: 8.5,
      date: DateTime.utc(2026, 4, 11, 14, 30),
      printer: 'Prusa MK4S',
      material: 'PETG',
      weight: 132,
      materialUsages: const [
        {'materialName': 'PETG Black', 'weightGrams': 132},
      ],
      timeHours: '05:10',
    ),
  ];
}

String generateSampleCsvPreview({int rowCount = 2, required String csvHeader}) {
  final sampleItems = buildSampleHistoryItems();
  final safeRowCount = rowCount.clamp(1, sampleItems.length);
  return generateCsv(sampleItems.take(safeRowCount).toList(), csvHeader);
}

Future<String> writeCsvToFile(String csv) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/3d_print_history.csv');
  await file.writeAsString(csv);

  return file.path;
}

Future<void> exportCSVFile(
  List<HistoryModel> items, {
  required String csvHeader,
  required String shareText,
}) async {
  // Get the CSV file content
  final csv = generateCsv(items, csvHeader);
  final path = await writeCsvToFile(csv);

  await SharePlus.instance.share(
    ShareParams(files: [XFile(path)], text: shareText),
  );
}

/// Range options for export
enum ExportRange { all, last7Days, last30Days }

/// Utility provider that can query history records and export CSVs.
class CsvUtils {
  final Ref ref;

  CsvUtils(this.ref);

  /// Instance wrapper for top-level generateCsv
  String generateCsvForItems(List<HistoryModel> items, String csvHeader) =>
      generateCsv(items, csvHeader);

  /// Instance wrapper for top-level writeCsvToFile
  Future<String> writeCsvFileToDisk(String csv) => writeCsvToFile(csv);

  /// Instance wrapper for top-level exportCSVFile
  Future<void> exportCsvForItems(
    List<HistoryModel> items, {
    required String csvHeader,
    required String shareText,
  }) => exportCSVFile(items, csvHeader: csvHeader, shareText: shareText);

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
  Future<void> exportForRange(
    ExportRange range, {
    required String csvHeader,
    required String shareText,
  }) async {
    final items = await queryHistory(range);
    await exportCSVFile(items, csvHeader: csvHeader, shareText: shareText);
  }
}

final csvUtilsProvider = Provider<CsvUtils>((ref) => CsvUtils(ref));
