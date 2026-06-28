import 'package:threed_print_cost_calculator/history/model/history_model.dart';

String _quote(Object? value) {
  final s = value?.toString() ?? '';
  final escaped = s.replaceAll('"', '""');
  return '"$escaped"';
}

String _sanitizeForCsv(String input) {
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
          final name = _sanitizeForCsv(rawName);
          final weight = _sanitizeForCsv(
            usage['weightGrams']?.toString() ?? '0',
          );
          return '$name:${weight}g';
        })
        .join('; ');
    buffer.writeln(
      '${_quote(_sanitizeForCsv(item.date.toIso8601String()))},'
      '${_quote(_sanitizeForCsv(item.printer))},'
      '${_quote(_sanitizeForCsv(item.material))},'
      '${_quote(materialsFlattened)},'
      '${_quote(item.weight)},'
      '${_quote(item.timeHours)},'
      '${_quote(item.electricityCost)},'
      '${_quote(item.filamentCost)},'
      '${_quote(item.labourCost)},'
      '${_quote(item.riskCost)},'
      '${_quote(item.totalCost)},'
      '${_quote(item.pricingMarkupPercent?.toString() ?? '')},'
      '${_quote(item.pricingMarkupAmount?.toString() ?? '')},'
      '${_quote(item.pricingSetupFee?.toString() ?? '')},'
      '${_quote(_sanitizeForCsv(item.pricingRoundingMode ?? ''))},'
      '${_quote(item.pricingSubtotalBeforeRounding?.toString() ?? '')},'
      '${_quote(item.pricingRoundingAdjustment?.toString() ?? '')},'
      '${_quote(item.finalPrice?.toString() ?? '')}',
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
  final quoteName = _quote(_sanitizeForCsv(item.name));
  final createdDate = _quote(_sanitizeForCsv(item.date.toIso8601String()));
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  final totalPrintTime = _formatDurationFromMinutes(
    summary['totalPrintDurationMinutes'],
  );
  final quoteId = '';
  buffer.writeln(
    [
      _quote('summary'),
      _quote(quoteId),
      quoteName,
      createdDate,
      _quote((summary['itemCount'] as num?)?.toInt() ?? 0),
      _quote((summary['totalQuantity'] as num?)?.toInt() ?? 0),
      _quote((summary['totalWeightG'] as num?)?.toDouble() ?? 0.0),
      _quote(totalPrintTime),
      _quote((summary['finalTotal'] as num?)?.toString() ?? ''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
      _quote(''),
    ].join(','),
  );
  final pricing = summary['pricing'];
  if (pricing is Map) {
    buffer.writeln(
      [
        _quote('pricing'),
        _quote(quoteId),
        quoteName,
        createdDate,
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(_pricingFieldValue(pricing, 'labourRate')),
        _quote(_pricingFieldValue(pricing, 'failureRisk')),
        _quote(_pricingFieldValue(pricing, 'markupPercent')),
        _quote(_pricingFieldValue(pricing, 'setupFee')),
        _quote(''),
        _quote(''),
      ].join(','),
    );
  }
  for (final batchItem in item.batchQuoteItems) {
    final itemName = _quote(
      _sanitizeForCsv(batchItem['name']?.toString() ?? ''),
    );
    final quantity = batchItem['quantity']?.toString() ?? '0';
    final source = _quote(
      batchItem['id']?.toString().startsWith('manual_') == true
          ? 'Manual'
          : 'G-code',
    );
    buffer.writeln(
      [
        _quote('item'),
        _quote(quoteId),
        quoteName,
        createdDate,
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        itemName,
        _quote(quantity),
        source,
        _quote(batchItem['printerId']?.toString() ?? ''),
        _quote(batchItem['materialId']?.toString() ?? ''),
        _quote(batchItem['baseCost']?.toString() ?? ''),
        _quote(batchItem['additionalCost']?.toString() ?? ''),
        _quote(batchItem['finalTotal']?.toString() ?? ''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
        _quote(''),
      ].join(','),
    );
  }
  final printerMode = summary['printerAssignmentMode']?.toString();
  final materialMode = summary['materialAssignmentMode']?.toString();
  if (printerMode == 'perItem' || materialMode == 'perItem') {
    if (printerMode == 'perItem') {
      buffer.writeln(
        [
          _quote('allocation'),
          _quote(quoteId),
          quoteName,
          createdDate,
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote('Printer split (per-item)'),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote('per-item'),
          _quote(''),
        ].join(','),
      );
    }
    if (materialMode == 'perItem') {
      buffer.writeln(
        [
          _quote('allocation'),
          _quote(quoteId),
          quoteName,
          createdDate,
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote('Material split (per-item)'),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote(''),
          _quote('per-item'),
          _quote(''),
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
    'single_print,${_quote(_sanitizeForCsv(item.date.toIso8601String()))},${_quote(_sanitizeForCsv(item.name))},${_quote(_sanitizeForCsv(item.printer))},${_quote(_sanitizeForCsv(item.material))},${_quote(item.weight)},${_quote(item.timeHours)},${_quote(item.totalCost)},${_quote(item.pricingMarkupPercent?.toString() ?? '')},${_quote(item.pricingSetupFee?.toString() ?? '')},${_quote(item.finalPrice?.toString() ?? '')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')}',
  );
}

void _writeBatchQuoteRows(StringBuffer buffer, HistoryModel item) {
  final dateStr = _quote(_sanitizeForCsv(item.date.toIso8601String()));
  final quoteName = _quote(_sanitizeForCsv(item.name));
  final summary = item.batchQuoteSummary ?? const <String, dynamic>{};
  buffer.writeln(
    'batch_quote,$dateStr,$quoteName,${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote(item.totalCost)},${_quote('')},${_quote('')},${_quote((summary['finalTotal'] as num?)?.toString() ?? '')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')}',
  );
  for (final batchItem in item.batchQuoteItems) {
    buffer.writeln(
      'batch_item,$dateStr,$quoteName,${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote(_sanitizeForCsv(batchItem['name']?.toString() ?? ''))},${_quote(batchItem['quantity']?.toString() ?? '0')},${_quote(batchItem['id']?.toString().startsWith('manual_') == true ? 'Manual' : 'G-code')},${_quote(batchItem['baseCost']?.toString() ?? '')},${_quote(batchItem['finalTotal']?.toString() ?? '')},${_quote('')},${_quote('')}',
    );
  }
  final printerMode = summary['printerAssignmentMode']?.toString();
  final materialMode = summary['materialAssignmentMode']?.toString();
  if (printerMode == 'perItem' || materialMode == 'perItem') {
    if (printerMode == 'perItem') {
      buffer.writeln(
        'batch_allocation,$dateStr,$quoteName,${_quote('printer split')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('per-item')},${_quote('')}',
      );
    }
    if (materialMode == 'perItem') {
      buffer.writeln(
        'batch_allocation,$dateStr,$quoteName,${_quote('')},${_quote('material split')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('')},${_quote('per-item')},${_quote('')}',
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
