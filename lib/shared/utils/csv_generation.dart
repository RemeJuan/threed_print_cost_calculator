import 'package:threed_print_cost_calculator/history/model/history_model.dart';

String quoteCsvCell(Object? value) {
  final s = value?.toString() ?? '';
  final escaped = s.replaceAll('"', '""');
  return '"$escaped"';
}

String sanitizeCsvSpreadsheetCell(String input) {
  if (input.isEmpty) return input;
  var firstIndex = 0;
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

String generateCsv(List<HistoryModel> items, String csvHeader) {
  final buffer = StringBuffer()..writeln(csvHeader);
  for (final item in items) {
    final materialsFlattened = item.materialUsages
        .map((usage) {
          final rawName =
              usage['materialName']?.toString() ??
              usage['materialId']?.toString() ??
              'Material';
          final name = sanitizeCsvSpreadsheetCell(rawName);
          final weight = sanitizeCsvSpreadsheetCell(
            usage['weightGrams']?.toString() ?? '0',
          );
          return '$name:${weight}g';
        })
        .join('; ');
    buffer.writeln(
      '${quoteCsvCell(sanitizeCsvSpreadsheetCell(item.date.toIso8601String()))},'
      '${quoteCsvCell(sanitizeCsvSpreadsheetCell(item.printer))},'
      '${quoteCsvCell(sanitizeCsvSpreadsheetCell(item.material))},'
      '${quoteCsvCell(materialsFlattened)},'
      '${quoteCsvCell(item.weight)},'
      '${quoteCsvCell(item.timeHours)},'
      '${quoteCsvCell(item.electricityCost)},'
      '${quoteCsvCell(item.filamentCost)},'
      '${quoteCsvCell(item.labourCost)},'
      '${quoteCsvCell(item.riskCost)},'
      '${quoteCsvCell(item.totalCost)},'
      '${quoteCsvCell(item.pricingMarkupPercent?.toString() ?? '')},'
      '${quoteCsvCell(item.pricingMarkupAmount?.toString() ?? '')},'
      '${quoteCsvCell(item.pricingSetupFee?.toString() ?? '')},'
      '${quoteCsvCell(sanitizeCsvSpreadsheetCell(item.pricingRoundingMode ?? ''))},'
      '${quoteCsvCell(item.pricingSubtotalBeforeRounding?.toString() ?? '')},'
      '${quoteCsvCell(item.pricingRoundingAdjustment?.toString() ?? '')},'
      '${quoteCsvCell(item.finalPrice?.toString() ?? '')}',
    );
  }
  return buffer.toString();
}

List<HistoryModel> buildSampleHistoryItems() => [
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

String generateSampleCsvPreview({int rowCount = 2, required String csvHeader}) {
  final sampleItems = buildSampleHistoryItems();
  final safeRowCount = rowCount.clamp(1, sampleItems.length);
  return generateCsv(sampleItems.take(safeRowCount).toList(), csvHeader);
}

const batchQuoteCsvHeader =
    'Section,Quote ID,Quote Name,Created Date,Item Count,Total Copies,'
    'Total Weight (g),Total Print Time,Final Total,Currency,'
    'Item Name,Quantity,Source,Printer,Material,Base Cost,'
    'Additional Cost,Item Total,Labour Rate,Risk %,Markup %,Setup Fee,'
    'Allocation Target,Allocation Copies';

String generateBatchQuoteCsv(HistoryModel item) {
  if (!item.batchQuote) {
    throw ArgumentError('HistoryModel is not a batch quote');
  }
  final buffer = StringBuffer()..writeln(batchQuoteCsvHeader);
  final quoteName = quoteCsvCell(sanitizeCsvSpreadsheetCell(item.name));
  final createdDate = quoteCsvCell(
    sanitizeCsvSpreadsheetCell(item.date.toIso8601String()),
  );
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  final totalPrintTime = _formatDurationFromMinutes(
    summary['totalPrintDurationMinutes'],
  );
  final quoteId = '';
  buffer.writeln(
    [
      quoteCsvCell('summary'),
      quoteCsvCell(quoteId),
      quoteName,
      createdDate,
      quoteCsvCell((summary['itemCount'] as num?)?.toInt() ?? 0),
      quoteCsvCell((summary['totalQuantity'] as num?)?.toInt() ?? 0),
      quoteCsvCell((summary['totalWeightG'] as num?)?.toDouble() ?? 0.0),
      quoteCsvCell(totalPrintTime),
      quoteCsvCell((summary['finalTotal'] as num?)?.toString() ?? ''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
      quoteCsvCell(''),
    ].join(','),
  );
  final pricing = summary['pricing'];
  if (pricing is Map) {
    buffer.writeln(
      [
        quoteCsvCell('pricing'),
        quoteCsvCell(quoteId),
        quoteName,
        createdDate,
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(_pricingFieldValue(pricing, 'labourRate')),
        quoteCsvCell(_pricingFieldValue(pricing, 'failureRisk')),
        quoteCsvCell(_pricingFieldValue(pricing, 'markupPercent')),
        quoteCsvCell(_pricingFieldValue(pricing, 'setupFee')),
        quoteCsvCell(''),
        quoteCsvCell(''),
      ].join(','),
    );
  }
  for (final batchItem in item.batchQuoteItems) {
    final itemName = quoteCsvCell(
      sanitizeCsvSpreadsheetCell(batchItem['name']?.toString() ?? ''),
    );
    final quantity = batchItem['quantity']?.toString() ?? '0';
    final source = quoteCsvCell(
      batchItem['id']?.toString().startsWith('manual_') == true
          ? 'Manual'
          : 'G-code',
    );
    buffer.writeln(
      [
        quoteCsvCell('item'),
        quoteCsvCell(quoteId),
        quoteName,
        createdDate,
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        itemName,
        quoteCsvCell(quantity),
        source,
        quoteCsvCell(batchItem['printerId']?.toString() ?? ''),
        quoteCsvCell(batchItem['materialId']?.toString() ?? ''),
        quoteCsvCell(batchItem['baseCost']?.toString() ?? ''),
        quoteCsvCell(batchItem['additionalCost']?.toString() ?? ''),
        quoteCsvCell(batchItem['finalTotal']?.toString() ?? ''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
        quoteCsvCell(''),
      ].join(','),
    );
  }
  final printerMode = summary['printerAssignmentMode']?.toString();
  final materialMode = summary['materialAssignmentMode']?.toString();
  if (printerMode == 'perItem' || materialMode == 'perItem') {
    if (printerMode == 'perItem') {
      buffer.writeln(
        [
          quoteCsvCell('allocation'),
          quoteCsvCell(quoteId),
          quoteName,
          createdDate,
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell('Printer split (per-item)'),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell('per-item'),
          quoteCsvCell(''),
        ].join(','),
      );
    }
    if (materialMode == 'perItem') {
      buffer.writeln(
        [
          quoteCsvCell('allocation'),
          quoteCsvCell(quoteId),
          quoteName,
          createdDate,
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell('Material split (per-item)'),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell(''),
          quoteCsvCell('per-item'),
          quoteCsvCell(''),
        ].join(','),
      );
    }
  }
  return buffer.toString();
}

String generateMixedHistoryCsv(List<HistoryModel> items) {
  const header =
      'record_type,Date,Name,Printer,Material,Weight (g),Time,Total Cost,Markup %,Setup Fee,Final Price,Batch Quote Name,Item Name,Quantity,Source,Base Cost,Item Total,Allocation Target,Allocation Copies';
  final buffer = StringBuffer()..writeln(header);
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
  buffer.writeln(
    'single_print,${quoteCsvCell(sanitizeCsvSpreadsheetCell(item.date.toIso8601String()))},${quoteCsvCell(sanitizeCsvSpreadsheetCell(item.name))},${quoteCsvCell(sanitizeCsvSpreadsheetCell(item.printer))},${quoteCsvCell(sanitizeCsvSpreadsheetCell(item.material))},${quoteCsvCell(item.weight)},${quoteCsvCell(item.timeHours)},${quoteCsvCell(item.totalCost)},${quoteCsvCell(item.pricingMarkupPercent?.toString() ?? '')},${quoteCsvCell(item.pricingSetupFee?.toString() ?? '')},${quoteCsvCell(item.finalPrice?.toString() ?? '')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')}',
  );
}

void _writeBatchQuoteRows(StringBuffer buffer, HistoryModel item) {
  final dateStr = quoteCsvCell(
    sanitizeCsvSpreadsheetCell(item.date.toIso8601String()),
  );
  final quoteName = quoteCsvCell(sanitizeCsvSpreadsheetCell(item.name));
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  buffer.writeln(
    'batch_quote,$dateStr,$quoteName,${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell(item.totalCost)},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell((summary['finalTotal'] as num?)?.toString() ?? '')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')}',
  );
  for (final batchItem in item.batchQuoteItems) {
    buffer.writeln(
      'batch_item,$dateStr,$quoteName,${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell(sanitizeCsvSpreadsheetCell(batchItem['name']?.toString() ?? ''))},${quoteCsvCell(batchItem['quantity']?.toString() ?? '0')},${quoteCsvCell(batchItem['id']?.toString().startsWith('manual_') == true ? 'Manual' : 'G-code')},${quoteCsvCell(batchItem['baseCost']?.toString() ?? '')},${quoteCsvCell(batchItem['finalTotal']?.toString() ?? '')},${quoteCsvCell('')},${quoteCsvCell('')}',
    );
  }
  final printerMode = summary['printerAssignmentMode']?.toString();
  final materialMode = summary['materialAssignmentMode']?.toString();
  if (printerMode == 'perItem' || materialMode == 'perItem') {
    if (printerMode == 'perItem') {
      buffer.writeln(
        'batch_allocation,$dateStr,$quoteName,${quoteCsvCell('printer split')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('per-item')},${quoteCsvCell('')}',
      );
    }
    if (materialMode == 'perItem') {
      buffer.writeln(
        'batch_allocation,$dateStr,$quoteName,${quoteCsvCell('')},${quoteCsvCell('material split')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('')},${quoteCsvCell('per-item')},${quoteCsvCell('')}',
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
