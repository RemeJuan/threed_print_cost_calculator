import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';

ProviderContainer _createContainer() {
  return ProviderContainer(
    overrides: [
      premiumAccessPolicyProvider.overrideWithValue(
        DefaultPremiumAccessPolicy(isPremium: true, hideProPromotions: false),
      ),
    ],
  );
}

void main() {
  group('item CRUD', () {
    test('adds, updates, removes, and resets items', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 1,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );

      notifier.addItem(item);
      expect(container.read(batchCostingProvider).items, [item]);
      expect(() => notifier.addItem(item), throwsArgumentError);

      final updated = item.copyWith(quantity: 4, printWeightG: 60);
      notifier.updateItem(updated);
      expect(container.read(batchCostingProvider).items.single.quantity, 4);

      notifier.removeItem('item-1');
      expect(container.read(batchCostingProvider).items, isEmpty);

      notifier.reset();
      expect(container.read(batchCostingProvider).items, isEmpty);
    });

    test('updateItem with quantity change clears per-item allocations', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 3,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setPrinterAssignmentMode(BatchPrinterAssignmentMode.perItem);
      notifier.setItemPrinterAllocations('item-1', [
        const BatchAssignmentAllocation(targetId: 'p1', quantity: 3),
      ]);

      expect(
        container
            .read(batchCostingProvider)
            .itemPrinterAllocations
            .containsKey('item-1'),
        isTrue,
      );

      final cleared = notifier.updateItem(item.copyWith(quantity: 5));
      expect(cleared, isTrue);
      expect(
        container
            .read(batchCostingProvider)
            .itemPrinterAllocations
            .containsKey('item-1'),
        isFalse,
      );
    });

    test('updateItem with quantity change keeps batch-wide allocations', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 3,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setBatchPrinterId('p1');

      final cleared = notifier.updateItem(item.copyWith(quantity: 5));
      expect(cleared, isFalse);
      expect(
        container
            .read(batchCostingProvider)
            .itemPrinterAllocations['item-1']!
            .single
            .quantity,
        5,
      );
    });

    test('removeItem cleans up allocation maps', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 1,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setItemPrinterAllocations('item-1', [
        const BatchAssignmentAllocation(targetId: 'p1', quantity: 1),
      ]);
      notifier.setItemMaterialAllocations('item-1', [
        const BatchAssignmentAllocation(targetId: 'm1', quantity: 1),
      ]);

      notifier.removeItem('item-1');
      final state = container.read(batchCostingProvider);
      expect(state.items, isEmpty);
      expect(state.itemPrinterAllocations, isEmpty);
      expect(state.itemPrinterIds, isEmpty);
      expect(state.itemMaterialAllocations, isEmpty);
    });
  });

  group('printer assignment', () {
    test('stores batch-wide printer assignment', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 1,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setPrinterAssignmentMode(BatchPrinterAssignmentMode.batchWide);
      notifier.setBatchPrinterId('printer-1');

      final state = container.read(batchCostingProvider);
      expect(state.printerAssignmentMode, BatchPrinterAssignmentMode.batchWide);
      expect(state.batchPrinterId, 'printer-1');
      expect(state.itemPrinterIds['item-1'], 'printer-1');
    });

    test('clears batch printer id but keeps existing item-level maps', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 1,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setBatchPrinterId('p1');
      notifier.setBatchPrinterId(null);

      final state = container.read(batchCostingProvider);
      expect(state.batchPrinterId, isNull);
      expect(state.itemPrinterIds['item-1'], 'p1');
    });

    test('stores per-item printer allocations', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 1,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setPrinterAssignmentMode(BatchPrinterAssignmentMode.perItem);
      notifier.setItemPrinterAllocations('item-1', [
        const BatchAssignmentAllocation(targetId: 'printer-2', quantity: 1),
      ]);

      final state = container.read(batchCostingProvider);
      expect(state.itemPrinterIds['item-1'], 'printer-2');
      expect(
        state.itemPrinterAllocations['item-1']!.single.targetId,
        'printer-2',
      );
    });

    test('normalizes printer allocations to item quantity', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 5,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setPrinterAssignmentMode(BatchPrinterAssignmentMode.perItem);
      notifier.setItemPrinterAllocations('item-1', [
        const BatchAssignmentAllocation(targetId: 'p1', quantity: 1),
      ]);

      expect(
        container
            .read(batchCostingProvider)
            .itemPrinterAllocations['item-1']!
            .single
            .quantity,
        5,
      );
    });
  });

  group('material assignment', () {
    test('stores batch-wide material assignment', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 2,
        printWeightG: 20,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setMaterialAssignmentMode(BatchMaterialAssignmentMode.batchWide);
      notifier.setBatchMaterialId('m1');

      final state = container.read(batchCostingProvider);
      expect(
        state.materialAssignmentMode,
        BatchMaterialAssignmentMode.batchWide,
      );
      expect(state.batchMaterialId, 'm1');
      expect(state.items.first.materialId, 'm1');
      expect(state.itemMaterialAllocations['item-1']!.single.targetId, 'm1');
    });

    test('clears batch material id but keeps existing item data', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 1,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setBatchMaterialId('m1');
      notifier.setBatchMaterialId(null);

      final state = container.read(batchCostingProvider);
      expect(state.batchMaterialId, isNull);
      expect(state.items.first.materialId, 'm1');
    });

    test('per-item material mode with existing batch id sets all items', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final a = BatchCostingItem.manual(
        id: 'a',
        displayName: 'A',
        quantity: 1,
        printWeightG: 10,
        printDuration: const Duration(minutes: 10),
      );
      final b = BatchCostingItem.manual(
        id: 'b',
        displayName: 'B',
        quantity: 1,
        printWeightG: 10,
        printDuration: const Duration(minutes: 10),
      );
      notifier.addItem(a);
      notifier.addItem(b);
      notifier.setBatchMaterialId('m1');
      notifier.setMaterialAssignmentMode(BatchMaterialAssignmentMode.perItem);

      expect(
        container
            .read(batchCostingProvider)
            .items
            .every((i) => i.materialId == 'm1'),
        isTrue,
      );
    });

    test('stores per-item material allocations', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      final item = BatchCostingItem.manual(
        id: 'item-1',
        displayName: 'Benchy',
        quantity: 1,
        printWeightG: 15,
        printDuration: const Duration(minutes: 30),
      );
      notifier.addItem(item);
      notifier.setMaterialAssignmentMode(BatchMaterialAssignmentMode.perItem);
      notifier.setItemMaterialAllocations('item-1', [
        const BatchAssignmentAllocation(targetId: 'm2', quantity: 1),
      ]);

      expect(
        container
            .read(batchCostingProvider)
            .itemMaterialAllocations['item-1']!
            .single
            .targetId,
        'm2',
      );
    });
  });

  group('pricing', () {
    test('sets and clears pricing fields', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      notifier.setFailureRisk('5');
      notifier.setFailureRiskScope(BatchPricingScope.batch);
      var pricing = container.read(batchCostingProvider).pricing;
      expect(pricing.failureRisk.value, '5');
      expect(pricing.failureRisk.scope, BatchPricingScope.batch);

      notifier.setMarkupPercent('10');
      notifier.setMarkupPercentScope(BatchPricingScope.item);
      pricing = container.read(batchCostingProvider).pricing;
      expect(pricing.markupPercent.value, '10');
      expect(pricing.markupPercent.scope, BatchPricingScope.item);

      notifier.setLabourRate('25');
      notifier.setLabourRateScope(BatchPricingScope.batch);
      pricing = container.read(batchCostingProvider).pricing;
      expect(pricing.labourRate.value, '25');
      expect(pricing.labourRate.scope, BatchPricingScope.batch);

      notifier.setAdditionalCostAmount('15');
      notifier.setAdditionalCostAmountScope(BatchPricingScope.item);
      pricing = container.read(batchCostingProvider).pricing;
      expect(pricing.additionalCostAmount.value, '15');
      expect(pricing.additionalCostAmount.scope, BatchPricingScope.item);
    });

    test('pricing fields are independent', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(batchCostingProvider.notifier);

      notifier.setFailureRisk('5');
      notifier.setMarkupPercent('10');

      final pricing = container.read(batchCostingProvider).pricing;
      expect(pricing.failureRisk.value, '5');
      expect(pricing.markupPercent.value, '10');
      expect(pricing.labourRate.value, isEmpty);
      expect(pricing.additionalCostAmount.value, isEmpty);
    });
  });
}
