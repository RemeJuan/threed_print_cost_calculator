import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/xlsx_export.dart';

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
    final markupPercent = item.pricingMarkupPercent?.toString() ?? '';
    final markupAmount = item.pricingMarkupAmount?.toString() ?? '';
    final setupFee = item.pricingSetupFee?.toString() ?? '';
    final roundingMode = _sanitizeForCsv(item.pricingRoundingMode ?? '');
    final pricingSubtotal =
        item.pricingSubtotalBeforeRounding?.toString() ?? '';
    final roundingAdjustment = item.pricingRoundingAdjustment?.toString() ?? '';
    final finalPrice = item.finalPrice?.toString() ?? '';

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
      '${_quote(total)},'
      '${_quote(markupPercent)},'
      '${_quote(markupAmount)},'
      '${_quote(setupFee)},'
      '${_quote(roundingMode)},'
      '${_quote(pricingSubtotal)},'
      '${_quote(roundingAdjustment)},'
      '${_quote(finalPrice)}',
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
      pricingMarkupPercent: 25,
      pricingMarkupAmount: 4.73,
      pricingSetupFee: 3,
      pricingRoundingMode: '.99',
      pricingSubtotalBeforeRounding: 26.63,
      pricingRoundingAdjustment: 0.36,
      finalPrice: 26.99,
      pricingUsedOverrides: false,
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

  /// Query and export mixed history (single-print + batch quotes) for the
  /// given [range]. Uses multi-sheet XLSX format by default.
  Future<void> exportMixedHistoryForRange(
    ExportRange range, {
    required String shareText,
  }) async {
    final policy = ref.read(premiumAccessPolicyProvider);
    if (!policy.bulkHistoryExport().allowed) return;

    final items = await queryHistory(range);
    final path = await generateMixedHistoryXlsx(items);
    await shareXlsxFile(path, shareText);
  }

  /// Export a single batch quote [HistoryModel] as multi-sheet XLSX.
  Future<void> exportBatchQuote(
    HistoryModel item, {
    required String shareText,
  }) async {
    final policy = ref.read(premiumAccessPolicyProvider);
    if (!policy.batchExport().allowed) return;

    final path = await generateBatchQuoteXlsx(item);
    await shareXlsxFile(path, shareText);
  }
}

final csvUtilsProvider = Provider<CsvUtils>((ref) => CsvUtils(ref));

// ─── Batch quote export ───────────────────────────────────────────────────

/// CSV header for a single batch quote export.
const batchQuoteCsvHeader =
    'Section,Quote ID,Quote Name,Created Date,Item Count,Total Copies,'
    'Total Weight (g),Total Print Time,Final Total,Currency,'
    'Item Name,Quantity,Source,Printer,Material,Base Cost,'
    'Additional Cost,Item Total,Labour Rate,Risk %,Markup %,Setup Fee,'
    'Allocation Target,Allocation Copies';

/// Generates a CSV export for a single batch quote [HistoryModel].
///
/// Produces a spreadsheet-friendly flat CSV with a `Section` column to
/// distinguish summary, item, and allocation rows.
String generateBatchQuoteCsv(HistoryModel item) {
  if (!item.batchQuote) {
    throw ArgumentError('HistoryModel is not a batch quote');
  }

  final buffer = StringBuffer();
  buffer.writeln(batchQuoteCsvHeader);

  final quoteId = ''; // No explicit ID stored; leave blank
  final quoteName = _quote(_sanitizeForCsv(item.name));
  final createdDate = _quote(_sanitizeForCsv(item.date.toIso8601String()));
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  final itemCount = (summary['itemCount'] as num?)?.toInt() ?? 0;
  final totalQuantity = (summary['totalQuantity'] as num?)?.toInt() ?? 0;
  final totalWeight = (summary['totalWeightG'] as num?)?.toDouble() ?? 0.0;
  final totalPrintTime = _formatDurationFromMinutes(
    summary['totalPrintDurationMinutes'],
  );
  final finalTotal = (summary['finalTotal'] as num?)?.toString() ?? '';
  final currency = ''; // Currency symbol not stored in summary

  // Summary row
  buffer.writeln(
    '${_quote('summary')},'
    '${_quote(quoteId)},'
    '$quoteName,'
    '$createdDate,'
    '${_quote(itemCount)},'
    '${_quote(totalQuantity)},'
    '${_quote(totalWeight)},'
    '${_quote(totalPrintTime)},'
    '${_quote(finalTotal)},'
    '${_quote(currency)},'
    '${_quote('')},' // Item Name
    '${_quote('')},' // Quantity
    '${_quote('')},' // Source
    '${_quote('')},' // Printer
    '${_quote('')},' // Material
    '${_quote('')},' // Base Cost
    '${_quote('')},' // Additional Cost
    '${_quote('')},' // Item Total
    '${_quote('')},' // Labour Rate
    '${_quote('')},' // Risk %
    '${_quote('')},' // Markup %
    '${_quote('')},' // Setup Fee
    '${_quote('')},' // Allocation Target
    '${_quote('')}', // Allocation Copies
  );

  // Pricing values from summary
  final pricing = summary['pricing'];
  if (pricing is Map) {
    final labourRate = _pricingFieldValue(pricing, 'labourRate');
    final riskValue = _pricingFieldValue(pricing, 'failureRisk');
    final markupValue = _pricingFieldValue(pricing, 'markupPercent');
    final setupFeeValue = _pricingFieldValue(pricing, 'additionalCostAmount');

    buffer.writeln(
      '${_quote('pricing')},'
      '${_quote(quoteId)},'
      '$quoteName,'
      '$createdDate,'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote(labourRate)},'
      '${_quote(riskValue)},'
      '${_quote(markupValue)},'
      '${_quote(setupFeeValue)},'
      '${_quote('')},'
      '${_quote('')}',
    );
  }

  // Batch item rows
  final items = item.batchQuoteItems;
  for (final batchItem in items) {
    final itemName = _quote(
      _sanitizeForCsv(batchItem['name']?.toString() ?? ''),
    );
    final quantity = batchItem['quantity']?.toString() ?? '0';
    final source = _quote(
      batchItem['id']?.toString().startsWith('manual_') == true
          ? 'Manual'
          : 'G-code',
    );
    final printer = _quote(batchItem['printerId']?.toString() ?? '');
    final material = _quote(batchItem['materialId']?.toString() ?? '');
    final baseCost = batchItem['baseCost']?.toString() ?? '';
    final additionalCost = batchItem['additionalCost']?.toString() ?? '';
    final itemTotal = batchItem['finalTotal']?.toString() ?? '';

    buffer.writeln(
      '${_quote('item')},'
      '${_quote(quoteId)},'
      '$quoteName,'
      '$createdDate,'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '$itemName,'
      '${_quote(quantity)},'
      '$source,'
      '$printer,'
      '$material,'
      '${_quote(baseCost)},'
      '${_quote(additionalCost)},'
      '${_quote(itemTotal)},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')},'
      '${_quote('')}',
    );
  }

  // Allocation rows for split assignments
  final printerMode = summary['printerAssignmentMode']?.toString();
  final materialMode = summary['materialAssignmentMode']?.toString();

  if (printerMode == 'perItem' || materialMode == 'perItem') {
    if (printerMode == 'perItem') {
      buffer.writeln(
        '${_quote('allocation')},'
        '${_quote(quoteId)},'
        '$quoteName,'
        '$createdDate,'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('Printer split (per-item)')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('per-item')},'
        '${_quote('')}',
      );
    }
    if (materialMode == 'perItem') {
      buffer.writeln(
        '${_quote('allocation')},'
        '${_quote(quoteId)},'
        '$quoteName,'
        '$createdDate,'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('Material split (per-item)')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('per-item')},'
        '${_quote('')}',
      );
    }
  }

  return buffer.toString();
}

/// Generates a flat CSV for mixed history containing both single-print and
/// batch quote records.
///
/// Uses a `record_type` column to distinguish row types:
/// - `single_print` — normal single-print history record
/// - `batch_quote` — batch quote summary row
/// - `batch_item` — individual batch item within a quote
/// - `batch_allocation` — split allocation row (if applicable)
String generateMixedHistoryCsv(List<HistoryModel> items) {
  const header =
      'record_type,Date,Name,Printer,Material,Weight (g),Time,'
      'Total Cost,Markup %,Setup Fee,Final Price,'
      'Batch Quote Name,Item Name,Quantity,Source,Base Cost,Item Total,'
      'Allocation Target,Allocation Copies';

  final buffer = StringBuffer();
  buffer.writeln(header);

  for (final item in items) {
    if (item.batchQuote) {
      _writeBatchQuoteRows(buffer, item);
    } else {
      _writeSinglePrintRow(buffer, item);
    }
  }

  return buffer.toString();
}

void _writeSinglePrintRow(StringBuffer buffer, HistoryModel item) {
  final dateStr = _quote(_sanitizeForCsv(item.date.toIso8601String()));
  final name = _quote(_sanitizeForCsv(item.name));
  final printer = _quote(_sanitizeForCsv(item.printer));
  final material = _quote(_sanitizeForCsv(item.material));
  final weight = _quote(item.weight);
  final time = _quote(item.timeHours);
  final totalCost = _quote(item.totalCost);
  final markupPercent = _quote(item.pricingMarkupPercent?.toString() ?? '');
  final setupFee = _quote(item.pricingSetupFee?.toString() ?? '');
  final finalPrice = _quote(item.finalPrice?.toString() ?? '');

  buffer.writeln(
    'single_print,'
    '$dateStr,'
    '$name,'
    '$printer,'
    '$material,'
    '$weight,'
    '$time,'
    '$totalCost,'
    '$markupPercent,'
    '$setupFee,'
    '$finalPrice,'
    '${_quote('')},' // Batch Quote Name
    '${_quote('')},' // Item Name
    '${_quote('')},' // Quantity
    '${_quote('')},' // Source
    '${_quote('')},' // Base Cost
    '${_quote('')},' // Item Total
    '${_quote('')},' // Allocation Target
    '${_quote('')}', // Allocation Copies
  );
}

void _writeBatchQuoteRows(StringBuffer buffer, HistoryModel item) {
  final dateStr = _quote(_sanitizeForCsv(item.date.toIso8601String()));
  final quoteName = _quote(_sanitizeForCsv(item.name));
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  final totalCost = _quote(item.totalCost);
  final finalTotal = (summary['finalTotal'] as num?)?.toString() ?? '';

  // Batch quote summary row
  buffer.writeln(
    'batch_quote,'
    '$dateStr,'
    '$quoteName,'
    '${_quote('')},' // Printer
    '${_quote('')},' // Material
    '${_quote('')},' // Weight
    '${_quote('')},' // Time
    '$totalCost,'
    '${_quote('')},' // Markup %
    '${_quote('')},' // Setup Fee
    '${_quote(finalTotal)},' // Final Price
    '${_quote('')},' // Batch Quote Name (redundant, leave blank)
    '${_quote('')},' // Item Name
    '${_quote('')},' // Quantity
    '${_quote('')},' // Source
    '${_quote('')},' // Base Cost
    '${_quote('')},' // Item Total
    '${_quote('')},' // Allocation Target
    '${_quote('')}', // Allocation Copies
  );

  // Batch item rows
  for (final batchItem in item.batchQuoteItems) {
    final itemName = _quote(
      _sanitizeForCsv(batchItem['name']?.toString() ?? ''),
    );
    final quantity = _quote(batchItem['quantity']?.toString() ?? '0');
    final source = _quote(
      batchItem['id']?.toString().startsWith('manual_') == true
          ? 'Manual'
          : 'G-code',
    );
    final baseCost = _quote(batchItem['baseCost']?.toString() ?? '');
    final itemTotal = _quote(batchItem['finalTotal']?.toString() ?? '');

    buffer.writeln(
      'batch_item,'
      '$dateStr,'
      '$quoteName,'
      '${_quote('')},' // Printer
      '${_quote('')},' // Material
      '${_quote('')},' // Weight
      '${_quote('')},' // Time
      '${_quote('')},' // Total Cost
      '${_quote('')},' // Markup %
      '${_quote('')},' // Setup Fee
      '${_quote('')},' // Final Price
      '${_quote('')},' // Batch Quote Name
      '$itemName,'
      '$quantity,'
      '$source,'
      '$baseCost,'
      '$itemTotal,'
      '${_quote('')},' // Allocation Target
      '${_quote('')}', // Allocation Copies
    );
  }

  // Allocation rows for split assignments
  final printerMode = summary['printerAssignmentMode']?.toString();
  final materialMode = summary['materialAssignmentMode']?.toString();

  if (printerMode == 'perItem' || materialMode == 'perItem') {
    // Allocations would need to be reconstructed from saved state.
    // For V1, we include a placeholder noting split allocations exist.
    // Full allocation detail requires the original BatchCostingState which
    // is not fully serialized. We note the mode instead.
    if (printerMode == 'perItem') {
      buffer.writeln(
        'batch_allocation,'
        '$dateStr,'
        '$quoteName,'
        '${_quote('printer split')},' // Printer
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('per-item')},' // Allocation Target
        '${_quote('')}', // Allocation Copies
      );
    }
    if (materialMode == 'perItem') {
      buffer.writeln(
        'batch_allocation,'
        '$dateStr,'
        '$quoteName,'
        '${_quote('')},'
        '${_quote('material split')},' // Material
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('')},'
        '${_quote('per-item')},' // Allocation Target
        '${_quote('')}', // Allocation Copies
      );
    }
  }
}

String _formatDurationFromMinutes(dynamic minutesValue) {
  final minutes = int.tryParse(minutesValue?.toString() ?? '') ?? 0;
  final hours = minutes ~/ 60;
  final mins = minutes.remainder(60);
  return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
}

String? _pricingFieldValue(Map pricing, String key) {
  final field = pricing[key];
  if (field is! Map) return null;
  return field['value']?.toString();
}
