import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

void main() {
  BatchCostingItem item({int quantity = 1, Duration? duration}) {
    return BatchCostingItem.manual(
      id: 'item-1',
      displayName: 'Benchy',
      quantity: quantity,
      printWeightG: 10,
      printDuration: duration ?? const Duration(hours: 1),
    );
  }

  const pla = MaterialModel(
    id: 'mat-1',
    name: 'PLA',
    cost: '20',
    color: 'Black',
    weight: '1000',
    archived: false,
  );

  test('quantity 1 defaults calculate a single item', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item().copyWith(itemLabourMinutes: 60)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
        ),
      ),
    );

    expect(summary.itemCount, 1);
    expect(summary.totalQuantity, 1);
    expect(summary.finalTotal, 10);
  });

  test('hands-on labour ignores print duration and scales item quantity', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [
          item(
            quantity: 3,
            duration: const Duration(minutes: 5),
          ).copyWith(itemLabourMinutes: 10),
        ],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '120'),
        ),
      ),
    );
    expect(summary.items.single.labourCost, 60);
    expect(summary.totalLabourCost, 60);
    expect(summary.totalPrintDuration, const Duration(minutes: 15));
  });

  test('setup labour counted once and receives batch risk and markup', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 3)],
        setupLabourMinutes: 15,
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(
            value: '120',
            scope: BatchPricingScope.item,
          ),
          failureRisk: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.batch,
          ),
          markupPercent: BatchPricingFieldState(
            value: '20',
            scope: BatchPricingScope.batch,
          ),
        ),
      ),
    );
    expect(summary.setupLabourCost, 30);
    expect(summary.totalLabourCost, 30);
    expect(summary.baseCost, 30);
    expect(summary.failureRiskMonetary, 3);
    expect(summary.markupPercentMonetary, 6.6);
    expect(summary.finalTotal, closeTo(39.6, 0.0001));
  });

  test('exposes customer-view cost components across item and batch scope', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [
          item(
            quantity: 2,
          ).copyWith(itemLabourMinutes: 30, materialId: 'mat-1'),
        ],
        setupLabourMinutes: 15,
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '60'),
          failureRisk: BatchPricingFieldState(value: '10'),
          markupPercent: BatchPricingFieldState(value: '20'),
          additionalCostAmount: BatchPricingFieldState(
            value: '4',
            scope: BatchPricingScope.batch,
          ),
        ),
      ),
      materialsById: {'mat-1': pla},
    );

    expect(summary.baseCost, 75.4);
    expect(summary.totalLabourCost, 75);
    expect(summary.totalElectricityCost, 0);
    expect(summary.totalMaterialCost, closeTo(0.4, 0.0001));
    expect(summary.itemAdditionalCost, 0);
    expect(summary.setupFee, 4);
    expect(summary.failureRiskMonetary, closeTo(6.04, 0.0001));
    expect(summary.finalTotal, greaterThan(summary.baseCost));
  });

  test('quantity greater than 1 multiplies totals', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 3).copyWith(itemLabourMinutes: 60)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
        ),
      ),
    );

    expect(summary.totalQuantity, 3);
    expect(summary.items.single.pricing.finalPrice, 30);
  });

  test('item scoped additional cost applies per item', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 2).copyWith(itemLabourMinutes: 60)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
          additionalCostAmount: BatchPricingFieldState(
            value: '5',
            scope: BatchPricingScope.item,
          ),
        ),
      ),
    );

    expect(summary.items.single.additionalCost, 10);
    expect(summary.finalTotal, 30);
  });

  test('batch scoped additional cost applies once', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 2).copyWith(itemLabourMinutes: 60)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
          additionalCostAmount: BatchPricingFieldState(
            value: '5',
            scope: BatchPricingScope.batch,
          ),
        ),
      ),
    );

    expect(summary.finalTotal, 25);
  });

  test('item scoped risk and markup stack on each item', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item().copyWith(itemLabourMinutes: 60)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
          failureRisk: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
          markupPercent: BatchPricingFieldState(
            value: '20',
            scope: BatchPricingScope.item,
          ),
        ),
      ),
    );

    expect(summary.finalTotal, 13.2);
  });

  test('batch scoped risk and markup apply after item totals', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item().copyWith(itemLabourMinutes: 60)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
          failureRisk: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.batch,
          ),
          markupPercent: BatchPricingFieldState(
            value: '20',
            scope: BatchPricingScope.batch,
          ),
        ),
      ),
    );

    expect(summary.finalTotal, 13.2);
  });

  test('mixed scopes keep per-item and batch adjustments separate', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 2).copyWith(itemLabourMinutes: 60)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
          additionalCostAmount: BatchPricingFieldState(
            value: '5',
            scope: BatchPricingScope.batch,
          ),
          markupPercent: BatchPricingFieldState(
            value: '10',
            scope: BatchPricingScope.item,
          ),
        ),
      ),
    );

    expect(summary.finalTotal, 27);
  });

  test('material cost contributes without labour pricing', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(items: [item()], batchMaterialId: pla.id),
      materialsById: {pla.id: pla},
    );

    expect(summary.items.single.baseCost, 0.2);
    expect(summary.finalTotal, 0.2);
  });

  test('split material allocations sum weighted material cost', () {
    const petg = MaterialModel(
      id: 'mat-2',
      name: 'PETG',
      cost: '30',
      color: 'Blue',
      weight: '500',
      archived: false,
    );

    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 3).copyWith(itemLabourMinutes: 0)],
        itemMaterialAllocations: const {
          'item-1': [
            BatchAssignmentAllocation(targetId: 'mat-1', quantity: 1),
            BatchAssignmentAllocation(targetId: 'mat-2', quantity: 2),
          ],
        },
      ),
      materialsById: {pla.id: pla, petg.id: petg},
    );

    expect(summary.items.single.baseCost, 1.40);
    expect(summary.finalTotal, 1.40);
  });

  test(
    'split printer electricity and total hours costing are included once',
    () {
      const printers = {
        'p1': PrinterModel(
          id: 'p1',
          name: 'A',
          bedSize: '220',
          wattage: '100',
          archived: false,
        ),
        'p2': PrinterModel(
          id: 'p2',
          name: 'B',
          bedSize: '220',
          wattage: '200',
          archived: false,
        ),
      };
      final summary = BatchSummaryCalculator.calculate(
        BatchCostingState(
          items: [item(quantity: 3).copyWith(itemLabourMinutes: 60)],
          itemPrinterAllocations: const {
            'item-1': [
              BatchAssignmentAllocation(targetId: 'p1', quantity: 1),
              BatchAssignmentAllocation(targetId: 'p2', quantity: 2),
            ],
          },
          pricing: const BatchPricingState(
            labourRate: BatchPricingFieldState(
              value: '10',
              scope: BatchPricingScope.item,
            ),
          ),
        ),
        printersById: printers,
        kwCost: 2,
      );
      expect(summary.totalPrintDuration, const Duration(hours: 3));
      expect(summary.totalLabourCost, 30);
      expect(summary.totalElectricityCost, closeTo(1, 0.0001));
      expect(summary.finalTotal, closeTo(31, 0.0001));
    },
  );
}
