import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/xlsx_export.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testDir = Directory.systemTemp.createTempSync('xlsx_export_test_');

  tearDownAll(() {
    if (testDir.existsSync()) {
      testDir.deleteSync(recursive: true);
    }
  });

  String? cellValue(dynamic cell) {
    if (cell == null) return null;
    final v = cell.value;
    if (v == null) return null;
    return v.toString();
  }

  group('xlsx_export.sanitizeForXlsx', () {
    test('returns empty string unchanged', () {
      expect(sanitizeForXlsx(''), '');
    });

    test('returns normal text unchanged', () {
      expect(sanitizeForXlsx('Hello World'), 'Hello World');
    });

    test('prefixes formula injection with single quote', () {
      expect(sanitizeForXlsx('=SUM(A1)'), "'=SUM(A1)");
      expect(sanitizeForXlsx('+A1'), "'+A1");
      expect(sanitizeForXlsx('-A1'), "'-A1");
      expect(sanitizeForXlsx('@SUM(A1)'), "'@SUM(A1)");
    });

    test('preserves leading whitespace before formula char', () {
      expect(sanitizeForXlsx(' =SUM(A1)'), "' =SUM(A1)");
    });
  });

  group('xlsx_export.generateMixedHistoryXlsx', () {
    test('creates XLSX file with correct sheets for mixed data', () async {
      final singlePrint = HistoryModel(
        name: 'Single Print',
        totalCost: 10.0,
        riskCost: 1.0,
        filamentCost: 5.0,
        electricityCost: 2.0,
        labourCost: 2.0,
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        printer: 'Printer A',
        material: 'PLA',
        weight: 50.0,
        timeHours: '02:00',
      );

      final batchQuote = HistoryModel.batchQuote(
        name: 'Test Batch',
        date: DateTime.parse('2025-06-16T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final path = await generateMixedHistoryXlsx(
        [singlePrint, batchQuote],
        outputDirectory: testDir,
      );
      final file = File(path);

      expect(file.existsSync(), isTrue);
      expect(path.endsWith('.xlsx'), isTrue);

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      expect(excel.tables.keys, contains('Single Prints'));
      expect(excel.tables.keys, contains('Batch Quotes'));
      expect(excel.tables.keys, contains('Batch Items'));
    });

    test('Single Prints sheet has correct headers and data', () async {
      final singlePrint = HistoryModel(
        name: 'Benchy',
        totalCost: 18.9,
        riskCost: 1.5,
        filamentCost: 9.8,
        electricityCost: 2.1,
        labourCost: 5.5,
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        printer: 'Bambu Lab A1',
        material: 'PLA',
        weight: 87.0,
        timeHours: '03:40',
        pricingMarkupPercent: 25,
        pricingMarkupAmount: 4.73,
        pricingSetupFee: 3,
        finalPrice: 26.99,
      );

      final path = await generateMixedHistoryXlsx(
        [singlePrint],
        outputDirectory: testDir,
      );
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables['Single Prints']!;

      final headers = sheet.rows[0].map(cellValue).toList();
      expect(headers, contains('Date'));
      expect(headers, contains('Name'));
      expect(headers, contains('Printer'));
      expect(headers, contains('Weight (g)'));

      final dataRow = sheet.rows[1];
      expect(cellValue(dataRow[1]), 'Benchy');
      expect(cellValue(dataRow[2]), 'Bambu Lab A1');
    });

    test('Batch Quotes sheet has summary rows', () async {
      final batchQuote = HistoryModel.batchQuote(
        name: 'Summary Test',
        date: DateTime.parse('2025-06-16T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final path = await generateMixedHistoryXlsx(
        [batchQuote],
        outputDirectory: testDir,
      );
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables['Batch Quotes']!;

      expect(sheet.rows.length, greaterThanOrEqualTo(2));
      final dataRow = sheet.rows[1];
      expect(cellValue(dataRow[0]), 'Summary Test');
    });

    test('Batch Items sheet has item rows with quantities and totals', () async {
      final batchQuote = HistoryModel.batchQuote(
        name: 'Item Test',
        date: DateTime.parse('2025-06-16T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final path = await generateMixedHistoryXlsx(
        [batchQuote],
        outputDirectory: testDir,
      );
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables['Batch Items']!;

      // Header + 2 items
      expect(sheet.rows.length, greaterThanOrEqualTo(3));
      final headers = sheet.rows[0].map(cellValue).toList();
      expect(headers, contains('Item Name'));
      expect(headers, contains('Quantity'));

      final itemRow = sheet.rows[1];
      expect(cellValue(itemRow[0]), 'Item Test');
      expect(cellValue(itemRow[1]), 'Benchy');
    });

    test('Batch Allocations sheet shows split allocations', () async {
      final stateWithSplits = BatchCostingState(
        items: [
          BatchCostingItem.manual(
            id: 'item1',
            displayName: 'Split Item',
            quantity: 5,
            printWeightG: 20.0,
            printDuration: const Duration(minutes: 30),
          ),
        ],
        printerAssignmentMode: BatchPrinterAssignmentMode.perItem,
        itemPrinterAllocations: {
          'item1': [
            const BatchAssignmentAllocation(targetId: 'printer_a', quantity: 3),
            const BatchAssignmentAllocation(targetId: 'printer_b', quantity: 2),
          ],
        },
        materialAssignmentMode: BatchMaterialAssignmentMode.perItem,
        itemMaterialAllocations: {
          'item1': [
            const BatchAssignmentAllocation(targetId: 'mat_a', quantity: 3),
            const BatchAssignmentAllocation(targetId: 'mat_b', quantity: 2),
          ],
        },
      );

      final summary = BatchSummaryCalculator.calculate(stateWithSplits);
      final batchQuote = HistoryModel.batchQuote(
        name: 'Split Test',
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        state: stateWithSplits,
        summary: summary,
      );

      final path = await generateMixedHistoryXlsx(
        [batchQuote],
        outputDirectory: testDir,
      );
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      expect(excel.tables.keys, contains('Batch Allocations'));
      final sheet = excel.tables['Batch Allocations']!;
      expect(sheet.rows.length, greaterThanOrEqualTo(1));
    });

    test('sanitizes user-entered text for formula injection', () async {
      final singlePrint = HistoryModel(
        name: '=HYPERLINK("http://evil.com")',
        totalCost: 10.0,
        riskCost: 1.0,
        filamentCost: 5.0,
        electricityCost: 2.0,
        labourCost: 2.0,
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        printer: 'Printer A',
        material: 'PLA',
        weight: 50.0,
        timeHours: '02:00',
      );

      final path = await generateMixedHistoryXlsx(
        [singlePrint],
        outputDirectory: testDir,
      );
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables['Single Prints']!;
      final dataRow = sheet.rows[1];

      final nameValue = cellValue(dataRow[1]);
      expect(nameValue, startsWith("'"));
      expect(nameValue, contains('=HYPERLINK'));
    });

    test('handles empty history gracefully', () async {
      final path = await generateMixedHistoryXlsx(
        [],
        outputDirectory: testDir,
      );
      final file = File(path);
      expect(file.existsSync(), isTrue);

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.keys, isNotEmpty);
    });

    test('mixed export with single prints and batch quotes works', () async {
      final singlePrint = HistoryModel(
        name: 'Single',
        totalCost: 10.0,
        riskCost: 1.0,
        filamentCost: 5.0,
        electricityCost: 2.0,
        labourCost: 2.0,
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        printer: 'Printer A',
        material: 'PLA',
        weight: 50.0,
        timeHours: '02:00',
      );

      final batchQuote = HistoryModel.batchQuote(
        name: 'Batch',
        date: DateTime.parse('2025-06-16T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final path = await generateMixedHistoryXlsx(
        [singlePrint, batchQuote],
        outputDirectory: testDir,
      );
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      expect(excel.tables.keys, contains('Single Prints'));
      expect(excel.tables.keys, contains('Batch Quotes'));
      expect(excel.tables.keys, contains('Batch Items'));
      expect(excel.tables.keys, contains('Batch Allocations'));
    });
  });

  group('xlsx_export.generateBatchQuoteXlsx', () {
    test('creates multi-sheet XLSX for single batch quote', () async {
      final batchQuote = HistoryModel.batchQuote(
        name: 'Full Quote',
        date: DateTime.parse('2025-06-16T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final path = await generateBatchQuoteXlsx(
        batchQuote,
        outputDirectory: testDir,
      );
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      expect(excel.tables.keys, contains('Quote Summary'));
      expect(excel.tables.keys, contains('Batch Items'));
      expect(excel.tables.keys, contains('Pricing'));
      expect(excel.tables.keys, contains('Allocations'));
    });

    test('Quote Summary sheet has correct data', () async {
      final batchQuote = HistoryModel.batchQuote(
        name: 'Summary Test',
        date: DateTime.parse('2025-06-16T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final path = await generateBatchQuoteXlsx(
        batchQuote,
        outputDirectory: testDir,
      );
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables['Quote Summary']!;

      expect(cellValue(sheet.rows[0][1]), 'Summary Test');
      expect(sheet.rows.length, greaterThanOrEqualTo(7));
      expect(cellValue(sheet.rows[2][1]), '2');
      expect(cellValue(sheet.rows[3][1]), '8');
    });

    test('throws for non-batch quote HistoryModel', () async {
      final singlePrint = HistoryModel(
        name: 'Single',
        totalCost: 10.0,
        riskCost: 1.0,
        filamentCost: 5.0,
        electricityCost: 2.0,
        labourCost: 2.0,
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        printer: 'Printer A',
        material: 'PLA',
        weight: 50.0,
        timeHours: '02:00',
      );

      expect(
        () => generateBatchQuoteXlsx(
          singlePrint,
          outputDirectory: testDir,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

// ─── Test helpers ───────────────────────────────────────────────────────────

BatchCostingState _testBatchState() {
  return BatchCostingState(
    items: [
      BatchCostingItem.manual(
        id: 'item1',
        displayName: 'Benchy',
        quantity: 5,
        printWeightG: 20.0,
        printDuration: const Duration(minutes: 45),
      ),
      BatchCostingItem.manual(
        id: 'item2',
        displayName: 'Bracket',
        quantity: 3,
        printWeightG: 50.0,
        printDuration: const Duration(minutes: 90),
      ),
    ],
    batchPrinterId: 'printer_a',
    batchMaterialId: 'pla_white',
  );
}

BatchCostingItem _testItem1() {
  return BatchCostingItem.manual(
    id: 'item1',
    displayName: 'Benchy',
    quantity: 5,
    printWeightG: 20.0,
    printDuration: const Duration(minutes: 45),
  );
}

BatchCostingItem _testItem2() {
  return BatchCostingItem.manual(
    id: 'item2',
    displayName: 'Bracket',
    quantity: 3,
    printWeightG: 50.0,
    printDuration: const Duration(minutes: 90),
  );
}

BatchSummaryResult _testBatchSummary() {
  return BatchSummaryResult(
    itemCount: 2,
    totalQuantity: 8,
    totalWeightG: 250.0,
    totalPrintDuration: const Duration(minutes: 495),
    items: [
      BatchSummaryItemBreakdown(
        item: _testItem1(),
        totalQuantity: 5,
        totalWeightG: 100.0,
        totalPrintDuration: const Duration(minutes: 225),
        baseCost: 5.0,
        additionalCost: 0,
        pricing: const PricingResult(
          baseCost: 5.0,
          markupPercent: 0,
          markupAmount: 0,
          setupFee: 0,
          roundingMode: PricingRoundingMode.none,
          subtotalBeforeRounding: 5.0,
          roundingAdjustment: 0,
          finalPrice: 5.0,
        ),
      ),
      BatchSummaryItemBreakdown(
        item: _testItem2(),
        totalQuantity: 3,
        totalWeightG: 150.0,
        totalPrintDuration: const Duration(minutes: 270),
        baseCost: 10.0,
        additionalCost: 0,
        pricing: const PricingResult(
          baseCost: 10.0,
          markupPercent: 0,
          markupAmount: 0,
          setupFee: 0,
          roundingMode: PricingRoundingMode.none,
          subtotalBeforeRounding: 10.0,
          roundingAdjustment: 0,
          finalPrice: 10.0,
        ),
      ),
    ],
    additionalCost: 0,
    failureRisk: const BatchPricingFieldState(
      value: '0',
      scope: BatchPricingScope.item,
    ),
    markupPercent: const BatchPricingFieldState(
      value: '0',
      scope: BatchPricingScope.item,
    ),
    labourRate: const BatchPricingFieldState(
      value: '2.5',
      scope: BatchPricingScope.item,
    ),
    finalTotal: 15.0,
    failureRiskMonetary: 0,
    markupPercentMonetary: 0,
  );
}
