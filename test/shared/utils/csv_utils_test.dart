import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  const historyCsvHeader =
      'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total,Pricing Markup %,Pricing Markup,Pricing Setup Fee,Pricing Rounding,Pricing Subtotal,Pricing Rounding Adjustment,Final Price';

  group('csv_utils.generateCsv', () {
    test('generates header and properly quoted row for a single item', () {
      final item = HistoryModel(
        name: 'Test Print',
        totalCost: 7.14,
        riskCost: 0.12,
        filamentCost: 2.34,
        electricityCost: 1.23,
        labourCost: 3.45,
        date: DateTime.parse('2022-01-02T03:04:05Z'),
        printer: 'My,Printer',
        material: 'PLA "Red"',
        weight: 12.5,
        materialUsages: const [
          {'materialName': 'PLA Red', 'weightGrams': 12},
        ],
        timeHours: '01:30',
      );

      final csv = generateCsv([item], historyCsvHeader);

      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();

      expect(lines.length, 2);

      expect(lines[0], historyCsvHeader);

      // Note: date is output with toIso8601String, which includes milliseconds and Z
      final expectedDate = '2022-01-02T03:04:05.000Z';
      final expectedRow =
          '"$expectedDate","My,Printer","PLA ""Red""","PLA Red:12g","12.5","01:30","1.23","2.34","3.45","0.12","7.14","","","","","","",""';

      expect(lines[1], expectedRow);
    });

    test('handles empty list', () {
      final csv = generateCsv([], historyCsvHeader);
      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();
      expect(lines.length, 1);
      expect(lines[0], historyCsvHeader);
    });
  });

  group('CsvUtils.queryHistory', () {
    late Database db;
    late ProviderContainer container;
    late CsvUtils csvUtils;
    final store = stringMapStoreFactory.store('history');

    setUp(() async {
      final name = 'test_csv_${DateTime.now().microsecondsSinceEpoch}.db';
      db = await databaseFactoryMemory.openDatabase(name);
      // Ensure a clean history store for each test run
      await store.delete(db);
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      csvUtils = container.read(csvUtilsProvider);
    });

    tearDown(() async {
      await db.close();
      container.dispose();
    });

    test(
      'returns all records sorted by date descending for ExportRange.all',
      () async {
        final base = DateTime.parse('2023-02-15T12:00:00Z');
        final itemNew = HistoryModel(
          name: 'New',
          totalCost: 1,
          riskCost: 0,
          filamentCost: 0,
          electricityCost: 0,
          labourCost: 0,
          date: base,
          printer: 'P1',
          material: 'M1',
          weight: 1,
          timeHours: '00:10',
        );
        final item5 = itemNew.copyWith(date: base.subtract(Duration(days: 5)));
        final item10 = itemNew.copyWith(
          date: base.subtract(Duration(days: 10)),
        );

        // Ensure date stored as ISO8601 string to match CsvUtils expectations
        await store.add(db, {
          ...itemNew.toMap(),
          'date': itemNew.date.toIso8601String(),
        });
        await store.add(db, {
          ...item5.toMap(),
          'date': item5.date.toIso8601String(),
        });
        await store.add(db, {
          ...item10.toMap(),
          'date': item10.date.toIso8601String(),
        });

        final results = await csvUtils.queryHistory(ExportRange.all, now: base);

        expect(results.length, 3);
        // newest first
        expect(
          results[0].date.toIso8601String(),
          itemNew.date.toIso8601String(),
        );
        expect(results[1].date.toIso8601String(), item5.date.toIso8601String());
        expect(
          results[2].date.toIso8601String(),
          item10.date.toIso8601String(),
        );
      },
    );

    test(
      'returns only records within last 7 days for ExportRange.last7Days',
      () async {
        final base = DateTime.parse('2023-02-15T12:00:00Z');
        final itemNew = HistoryModel(
          name: 'New',
          totalCost: 1,
          riskCost: 0,
          filamentCost: 0,
          electricityCost: 0,
          labourCost: 0,
          date: base,
          printer: 'P1',
          material: 'M1',
          weight: 1,
          timeHours: '00:10',
        );
        final item5 = itemNew.copyWith(date: base.subtract(Duration(days: 5)));
        final item10 = itemNew.copyWith(
          date: base.subtract(Duration(days: 10)),
        );

        await store.add(db, {
          ...itemNew.toMap(),
          'date': itemNew.date.toIso8601String(),
        });
        await store.add(db, {
          ...item5.toMap(),
          'date': item5.date.toIso8601String(),
        });
        await store.add(db, {
          ...item10.toMap(),
          'date': item10.date.toIso8601String(),
        });

        final results = await csvUtils.queryHistory(
          ExportRange.last7Days,
          now: base,
        );

        expect(results.length, 2);
        expect(
          results[0].date.toIso8601String(),
          itemNew.date.toIso8601String(),
        );
        expect(results[1].date.toIso8601String(), item5.date.toIso8601String());
      },
    );

    test(
      'returns records within last 30 days for ExportRange.last30Days',
      () async {
        final base = DateTime.parse('2023-02-15T12:00:00Z');
        final itemNew = HistoryModel(
          name: 'New',
          totalCost: 1,
          riskCost: 0,
          filamentCost: 0,
          electricityCost: 0,
          labourCost: 0,
          date: base,
          printer: 'P1',
          material: 'M1',
          weight: 1,
          timeHours: '00:10',
        );
        final item5 = itemNew.copyWith(date: base.subtract(Duration(days: 5)));
        final item40 = itemNew.copyWith(
          date: base.subtract(Duration(days: 40)),
        );

        await store.add(db, {
          ...itemNew.toMap(),
          'date': itemNew.date.toIso8601String(),
        });
        await store.add(db, {
          ...item5.toMap(),
          'date': item5.date.toIso8601String(),
        });
        await store.add(db, {
          ...item40.toMap(),
          'date': item40.date.toIso8601String(),
        });

        final results = await csvUtils.queryHistory(
          ExportRange.last30Days,
          now: base,
        );

        expect(results.length, 2);
        expect(
          results.any(
            (r) => r.date.toIso8601String() == item40.date.toIso8601String(),
          ),
          isFalse,
        );
      },
    );
  });

  group('csv_utils.generateSampleCsvPreview', () {
    test('returns header and two sample rows by default', () {
      final csv = generateSampleCsvPreview(csvHeader: historyCsvHeader);
      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();

      expect(lines.length, 3);
      expect(lines[0], historyCsvHeader);
      expect(lines[1], contains('Bambu Lab A1'));
      expect(lines[2], contains('Prusa MK4S'));
    });
  });

  group('csv_utils.generateBatchQuoteCsv', () {
    test('generates batch quote CSV with summary, pricing, and item rows', () {
      final batchItem = HistoryModel.batchQuote(
        name: 'Test Batch Quote',
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final csv = generateBatchQuoteCsv(batchItem);
      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();

      // Header + summary row + pricing row + 2 item rows
      expect(lines.length, greaterThanOrEqualTo(4));
      expect(lines[0], batchQuoteCsvHeader);

      // Summary row should contain quote name and section='summary'
      expect(lines[1], contains('summary'));
      expect(lines[1], contains('Test Batch Quote'));

      // Item rows should contain section='item'
      final itemRows = lines.where((l) => l.contains('"item"')).toList();
      expect(itemRows.length, 2);
    });

    test('batch quote CSV includes item quantities and totals', () {
      final batchItem = HistoryModel.batchQuote(
        name: 'Quantity Test',
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final csv = generateBatchQuoteCsv(batchItem);
      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();

      // Find item rows and verify they contain quantity values
      final itemRows = lines.where((l) => l.contains('"item"')).toList();
      expect(itemRows.length, 2);

      // Item rows should contain the item name and quantity
      expect(itemRows[0], contains('Benchy'));
      expect(itemRows[0], contains('"5"'));
      expect(itemRows[1], contains('Bracket'));
      expect(itemRows[1], contains('"3"'));
    });

    test('sanitizes user-entered text for CSV injection', () {
      final batchItem = HistoryModel.batchQuote(
        name: '=HYPERLINK("http://evil.com")',
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final csv = generateBatchQuoteCsv(batchItem);

      // The malicious formula should be prefixed with a single quote
      expect(csv, contains("'=HYPERLINK"));
    });

    test('handles zero/blank optional values without junk rows', () {
      final batchItem = HistoryModel.batchQuote(
        name: 'Clean Values',
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final csv = generateBatchQuoteCsv(batchItem);
      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();

      // All lines should have consistent column count
      final headerColumns = lines[0].split(',').length;
      for (final line in lines) {
        expect(
          line.split(',').length,
          headerColumns,
          reason: 'Line should have same column count as header',
        );
      }
    });
  });

  group('csv_utils.generateMixedHistoryCsv', () {
    test('includes both single-print and batch records', () {
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
        name: 'Batch Quote',
        date: DateTime.parse('2025-06-16T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final csv = generateMixedHistoryCsv([singlePrint, batchQuote]);
      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();

      // Header + single_print row + batch_quote summary + batch items
      expect(lines.length, greaterThanOrEqualTo(3));

      // Should have record_type column
      expect(lines[0], contains('record_type'));

      // Should have single_print row
      final singleRows = lines.where((l) => l.startsWith('single_print')).toList();
      expect(singleRows.length, 1);

      // Should have batch_quote row
      final batchRows = lines.where((l) => l.startsWith('batch_quote')).toList();
      expect(batchRows.length, greaterThanOrEqualTo(1));
    });

    test('batch item rows include item quantities and totals', () {
      final batchQuote = HistoryModel.batchQuote(
        name: 'Item Details',
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        state: _testBatchState(),
        summary: _testBatchSummary(),
      );

      final csv = generateMixedHistoryCsv([batchQuote]);
      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();

      // Should have batch_item rows
      final itemRows = lines.where((l) => l.startsWith('batch_item')).toList();
      expect(itemRows.length, 2); // 2 items in test summary
    });

    test('split printer/material allocations are represented', () {
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
        name: 'Split Allocation Test',
        date: DateTime.parse('2025-06-15T10:00:00Z'),
        state: stateWithSplits,
        summary: summary,
      );

      final csv = generateMixedHistoryCsv([batchQuote]);

      // Should contain batch_allocation rows for split assignments
      expect(csv, contains('batch_allocation'));
      expect(csv, contains('printer split'));
      expect(csv, contains('material split'));
    });

    test('sanitizes user-entered text for CSV injection in mixed export', () {
      final singlePrint = HistoryModel(
        name: '+cmd.exe',
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

      final csv = generateMixedHistoryCsv([singlePrint]);

      // The malicious formula should be prefixed with a single quote
      expect(csv, contains("'+cmd.exe"));
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
