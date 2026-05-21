import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

/// Sanitizes a string for safe display in spreadsheet cells.
/// Prevents formula injection attacks (=, +, -, @ prefixes).
String sanitizeForXlsx(String input) {
  if (input.isEmpty) return input;
  int firstIndex = 0;
  while (firstIndex < input.length) {
    final cu = input.codeUnitAt(firstIndex);
    if (cu > 0x20) break;
    firstIndex++;
  }
  if (firstIndex >= input.length) return input;

  final firstChar = input[firstIndex];
  if (firstChar == '=' ||
      firstChar == '+' ||
      firstChar == '-' ||
      firstChar == '@') {
    return "'$input";
  }
  return input;
}

/// Generates a multi-sheet XLSX export for mixed history containing both
/// single-print records and batch quote records.
///
/// Sheets:
/// - Single Prints: existing single-print export fields
/// - Batch Quotes: one row per saved quote with summary data
/// - Batch Items: one row per batch item with detail
/// - Batch Allocations: split printer/material allocations
Future<String> generateMixedHistoryXlsx(
  List<HistoryModel> items, {
  Directory? outputDirectory,
}) async {
  final excel = Excel.createExcel();

  // Remove default sheet and create named sheets
  excel.delete('Sheet1');

  _buildSinglePrintsSheet(excel, items);
  _buildBatchQuotesSheet(excel, items);
  _buildBatchItemsSheet(excel, items);
  _buildBatchAllocationsSheet(excel, items);

  final bytes = excel.save();
  if (bytes == null) {
    throw StateError('Failed to generate XLSX file');
  }

  final directory = outputDirectory ?? await getTemporaryDirectory();
  final file = File('${directory.path}/3d_print_history.xlsx');
  await file.writeAsBytes(bytes);
  return file.path;
}

/// Generates a multi-sheet XLSX export for a single batch quote.
///
/// Sheets:
/// - Quote Summary: quote-level details
/// - Batch Items: item-level breakdown
/// - Pricing: pricing configuration and calculated values
/// - Allocations: printer/material allocation details
Future<String> generateBatchQuoteXlsx(
  HistoryModel item, {
  Directory? outputDirectory,
}) async {
  if (!item.batchQuote) {
    throw ArgumentError('HistoryModel is not a batch quote');
  }

  final excel = Excel.createExcel();
  excel.delete('Sheet1');

  _buildSingleQuoteSummarySheet(excel, item);
  _buildSingleQuoteItemsSheet(excel, item);
  _buildSingleQuotePricingSheet(excel, item);
  _buildSingleQuoteAllocationsSheet(excel, item);

  final bytes = excel.save();
  if (bytes == null) {
    throw StateError('Failed to generate XLSX file');
  }

  final directory = outputDirectory ?? await getTemporaryDirectory();
  final safeName = item.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  final file = File('${directory.path}/batch_quote_$safeName.xlsx');
  await file.writeAsBytes(bytes);
  return file.path;
}

/// Share an XLSX file with the given [filePath] and [shareText].
Future<void> shareXlsxFile(String filePath, String shareText) async {
  await SharePlus.instance.share(
    ShareParams(files: [XFile(filePath)], text: shareText),
  );
}

// ─── Mixed history sheets ──────────────────────────────────────────────────

void _buildSinglePrintsSheet(Excel excel, List<HistoryModel> items) {
  final singlePrints = items.where((i) => !i.batchQuote).toList();
  if (singlePrints.isEmpty) return;

  final sheet = excel['Single Prints'];

  // Header row
  final headers = [
    'Date',
    'Name',
    'Printer',
    'Material',
    'Weight (g)',
    'Time',
    'Electricity',
    'Filament',
    'Labour',
    'Risk',
    'Total',
    'Markup %',
    'Markup Amount',
    'Setup Fee',
    'Rounding Mode',
    'Subtotal Before Rounding',
    'Rounding Adjustment',
    'Final Price',
  ];
  _writeRow(sheet, 0, headers);

  // Data rows
  for (var i = 0; i < singlePrints.length; i++) {
    final item = singlePrints[i];
    _writeRow(sheet, i + 1, [
      item.date.toIso8601String(),
      sanitizeForXlsx(item.name),
      sanitizeForXlsx(item.printer),
      sanitizeForXlsx(item.material),
      item.weight,
      item.timeHours,
      item.electricityCost,
      item.filamentCost,
      item.labourCost,
      item.riskCost,
      item.totalCost,
      item.pricingMarkupPercent ?? '',
      item.pricingMarkupAmount ?? '',
      item.pricingSetupFee ?? '',
      item.pricingRoundingMode ?? '',
      item.pricingSubtotalBeforeRounding ?? '',
      item.pricingRoundingAdjustment ?? '',
      item.finalPrice ?? '',
    ]);
  }
}

void _buildBatchQuotesSheet(Excel excel, List<HistoryModel> items) {
  final batchQuotes = items.where((i) => i.batchQuote).toList();
  if (batchQuotes.isEmpty) return;

  final sheet = excel['Batch Quotes'];

  final headers = [
    'Quote Name',
    'Created Date',
    'Item Count',
    'Total Copies',
    'Total Weight (g)',
    'Total Print Time',
    'Final Total',
  ];
  _writeRow(sheet, 0, headers);

  for (var i = 0; i < batchQuotes.length; i++) {
    final item = batchQuotes[i];
    final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
    final totalPrintMinutes =
        (summary['totalPrintDurationMinutes'] as num?)?.toInt() ?? 0;
    final hours = totalPrintMinutes ~/ 60;
    final mins = totalPrintMinutes.remainder(60);
    final timeStr =
        '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';

    _writeRow(sheet, i + 1, [
      sanitizeForXlsx(item.name),
      item.date.toIso8601String(),
      (summary['itemCount'] as num?)?.toInt() ?? 0,
      (summary['totalQuantity'] as num?)?.toInt() ?? 0,
      (summary['totalWeightG'] as num?)?.toDouble() ?? 0.0,
      timeStr,
      (summary['finalTotal'] as num?)?.toDouble() ?? 0.0,
    ]);
  }
}

void _buildBatchItemsSheet(Excel excel, List<HistoryModel> items) {
  final batchQuotes = items.where((i) => i.batchQuote).toList();
  if (batchQuotes.isEmpty) return;

  final sheet = excel['Batch Items'];

  final headers = [
    'Quote Name',
    'Item Name',
    'Source',
    'Quantity',
    'Weight (g)',
    'Duration (min)',
    'Base Cost',
    'Additional Cost',
    'Item Total',
  ];
  _writeRow(sheet, 0, headers);

  var rowIndex = 1;
  for (final quote in batchQuotes) {
    for (final batchItem in quote.batchQuoteItems) {
      final source = batchItem['id']?.toString().startsWith('manual_') == true
          ? 'Manual'
          : 'G-code';
      final weight = batchItem['totalWeightG']?.toString() ?? '0';
      final duration =
          batchItem['totalPrintDurationMinutes']?.toString() ?? '0';

      _writeRow(sheet, rowIndex, [
        sanitizeForXlsx(quote.name),
        sanitizeForXlsx(batchItem['name']?.toString() ?? ''),
        source,
        batchItem['quantity']?.toString() ?? '0',
        weight,
        duration,
        batchItem['baseCost']?.toString() ?? '',
        batchItem['additionalCost']?.toString() ?? '',
        batchItem['finalTotal']?.toString() ?? '',
      ]);
      rowIndex++;
    }
  }
}

void _buildBatchAllocationsSheet(Excel excel, List<HistoryModel> items) {
  final batchQuotes = items.where((i) => i.batchQuote).toList();
  if (batchQuotes.isEmpty) return;

  final sheet = excel['Batch Allocations'];

  final headers = [
    'Quote Name',
    'Item Name',
    'Allocation Type',
    'Allocation Summary',
    'Allocated Quantity',
  ];
  _writeRow(sheet, 0, headers);

  var rowIndex = 1;
  for (final quote in batchQuotes) {
    final summary = quote.batchQuoteSummary ?? const <String, dynamic>{};
    final printerMode = summary['printerAssignmentMode']?.toString();
    final materialMode = summary['materialAssignmentMode']?.toString();

    if (printerMode == 'perItem') {
      _writeRow(sheet, rowIndex, [
        sanitizeForXlsx(quote.name),
        '(multiple items)',
        'Printer',
        'Split across printers (per-item mode)',
        '',
      ]);
      rowIndex++;
    }

    if (materialMode == 'perItem') {
      _writeRow(sheet, rowIndex, [
        sanitizeForXlsx(quote.name),
        '(multiple items)',
        'Material',
        'Split across materials (per-item mode)',
        '',
      ]);
      rowIndex++;
    }

    // Batch-wide assignments
    if (printerMode == 'batchWide') {
      final printerId = summary['batchPrinterId']?.toString();
      if (printerId != null && printerId.isNotEmpty) {
        _writeRow(sheet, rowIndex, [
          sanitizeForXlsx(quote.name),
          '(all items)',
          'Printer',
          sanitizeForXlsx(printerId),
          '(batch-wide)',
        ]);
        rowIndex++;
      }
    }

    if (materialMode == 'batchWide') {
      final materialId = summary['batchMaterialId']?.toString();
      if (materialId != null && materialId.isNotEmpty) {
        _writeRow(sheet, rowIndex, [
          sanitizeForXlsx(quote.name),
          '(all items)',
          'Material',
          sanitizeForXlsx(materialId),
          '(batch-wide)',
        ]);
        rowIndex++;
      }
    }
  }
}

// ─── Single batch quote sheets ─────────────────────────────────────────────

void _buildSingleQuoteSummarySheet(Excel excel, HistoryModel item) {
  final sheet = excel['Quote Summary'];
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  final totalPrintMinutes =
      (summary['totalPrintDurationMinutes'] as num?)?.toInt() ?? 0;
  final hours = totalPrintMinutes ~/ 60;
  final mins = totalPrintMinutes.remainder(60);
  final timeStr =
      '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';

  final rows = [
    ['Quote Name', sanitizeForXlsx(item.name)],
    ['Created Date', item.date.toIso8601String()],
    ['Item Count', (summary['itemCount'] as num?)?.toInt() ?? 0],
    ['Total Copies', (summary['totalQuantity'] as num?)?.toInt() ?? 0],
    ['Total Weight (g)', (summary['totalWeightG'] as num?)?.toDouble() ?? 0.0],
    ['Total Print Time', timeStr],
    ['Final Total', (summary['finalTotal'] as num?)?.toDouble() ?? 0.0],
  ];

  for (var i = 0; i < rows.length; i++) {
    _writeRow(sheet, i, rows[i]);
  }
}

void _buildSingleQuoteItemsSheet(Excel excel, HistoryModel item) {
  final sheet = excel['Batch Items'];

  final headers = [
    'Item Name',
    'Source',
    'Quantity',
    'Weight (g)',
    'Duration (min)',
    'Base Cost',
    'Additional Cost',
    'Item Total',
  ];
  _writeRow(sheet, 0, headers);

  for (var i = 0; i < item.batchQuoteItems.length; i++) {
    final batchItem = item.batchQuoteItems[i];
    final source = batchItem['id']?.toString().startsWith('manual_') == true
        ? 'Manual'
        : 'G-code';

    _writeRow(sheet, i + 1, [
      sanitizeForXlsx(batchItem['name']?.toString() ?? ''),
      source,
      batchItem['quantity']?.toString() ?? '0',
      batchItem['totalWeightG']?.toString() ?? '0',
      batchItem['totalPrintDurationMinutes']?.toString() ?? '0',
      batchItem['baseCost']?.toString() ?? '',
      batchItem['additionalCost']?.toString() ?? '',
      batchItem['finalTotal']?.toString() ?? '',
    ]);
  }
}

void _buildSingleQuotePricingSheet(Excel excel, HistoryModel item) {
  final sheet = excel['Pricing'];
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  final pricing = summary['pricing'];
  if (pricing is! Map) return;

  final headers = [
    'Pricing Type',
    'Scope',
    'Configured Value',
    'Calculated Impact',
  ];
  _writeRow(sheet, 0, headers);

  var rowIndex = 1;
  for (final entry in [
    ('Labour Rate', 'labourRate'),
    ('Failure Risk', 'failureRisk'),
    ('Markup %', 'markupPercent'),
    ('Additional Cost', 'additionalCostAmount'),
  ]) {
    final field = pricing[entry.$2];
    if (field is! Map) continue;
    final value = field['value']?.toString() ?? '';
    final scope = field['scope']?.toString() ?? '';
    final impact = field['monetaryImpact']?.toString() ?? '';

    _writeRow(sheet, rowIndex, [entry.$1, scope, value, impact]);
    rowIndex++;
  }
}

void _buildSingleQuoteAllocationsSheet(Excel excel, HistoryModel item) {
  final sheet = excel['Allocations'];
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  final printerMode = summary['printerAssignmentMode']?.toString();
  final materialMode = summary['materialAssignmentMode']?.toString();

  final headers = [
    'Allocation Type',
    'Assignment',
    'Details',
  ];
  _writeRow(sheet, 0, headers);

  var rowIndex = 1;

  if (printerMode == 'batchWide') {
    final printerId = summary['batchPrinterId']?.toString();
    if (printerId != null) {
      _writeRow(sheet, rowIndex, [
        'Printer',
        'Batch-wide',
        sanitizeForXlsx(printerId),
      ]);
      rowIndex++;
    }
  } else if (printerMode == 'perItem') {
    _writeRow(sheet, rowIndex, [
      'Printer',
      'Per-item split',
      'Items split across multiple printers',
    ]);
    rowIndex++;
  }

  if (materialMode == 'batchWide') {
    final materialId = summary['batchMaterialId']?.toString();
    if (materialId != null) {
      _writeRow(sheet, rowIndex, [
        'Material',
        'Batch-wide',
        sanitizeForXlsx(materialId),
      ]);
      rowIndex++;
    }
  } else if (materialMode == 'perItem') {
    _writeRow(sheet, rowIndex, [
      'Material',
      'Per-item split',
      'Items split across multiple materials',
    ]);
    rowIndex++;
  }
}

// ─── Helper ────────────────────────────────────────────────────────────────

void _writeRow(Sheet sheet, int rowIndex, List<dynamic> values) {
  for (var colIndex = 0; colIndex < values.length; colIndex++) {
    final cellIndex = CellIndex.indexByColumnRow(
      columnIndex: colIndex,
      rowIndex: rowIndex,
    );
    final value = values[colIndex];
    if (value is num) {
      sheet.cell(cellIndex).value = DoubleCellValue(value.toDouble());
    } else {
      sheet.cell(cellIndex).value = TextCellValue(value.toString());
    }
  }
}
