import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';

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

  test('quantity 1 defaults calculate a single item', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item()],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
        ),
      ),
    );

    expect(summary.itemCount, 1);
    expect(summary.totalQuantity, 1);
    expect(summary.finalTotal, 10);
  });

  test('quantity greater than 1 multiplies totals', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 3)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
        ),
      ),
    );

    expect(summary.totalQuantity, 3);
    expect(summary.items.single.pricing.finalPrice, 30);
  });

  test('item scoped additional cost applies per item', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 2)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
          additionalCostAmount: BatchPricingFieldState(value: '5', scope: BatchPricingScope.item),
        ),
      ),
    );

    expect(summary.items.single.additionalCost, 10);
    expect(summary.finalTotal, 30);
  });

  test('batch scoped additional cost applies once', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 2)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
          additionalCostAmount: BatchPricingFieldState(value: '5', scope: BatchPricingScope.batch),
        ),
      ),
    );

    expect(summary.finalTotal, 25);
  });

  test('item scoped risk and markup stack on each item', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item()],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
          failureRisk: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
          markupPercent: BatchPricingFieldState(value: '20', scope: BatchPricingScope.item),
        ),
      ),
    );

    expect(summary.finalTotal, 13.2);
  });

  test('batch scoped risk and markup apply after item totals', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item()],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
          failureRisk: BatchPricingFieldState(value: '10', scope: BatchPricingScope.batch),
          markupPercent: BatchPricingFieldState(value: '20', scope: BatchPricingScope.batch),
        ),
      ),
    );

    expect(summary.finalTotal, 13.2);
  });

  test('mixed scopes keep per-item and batch adjustments separate', () {
    final summary = BatchSummaryCalculator.calculate(
      BatchCostingState(
        items: [item(quantity: 2)],
        pricing: const BatchPricingState(
          labourRate: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
          additionalCostAmount: BatchPricingFieldState(value: '5', scope: BatchPricingScope.batch),
          markupPercent: BatchPricingFieldState(value: '10', scope: BatchPricingScope.item),
        ),
      ),
    );

    expect(summary.finalTotal, 27);
  });
}
