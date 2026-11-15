import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/material_allocation_row.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';

import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  final items = [
    BatchCostingItem.manual(
      id: 'item-1',
      displayName: 'Benchy',
      quantity: 2,
      printWeightG: 20,
      printDuration: const Duration(minutes: 30),
    ),
    BatchCostingItem.manual(
      id: 'item-2',
      displayName: 'Cube',
      quantity: 1,
      printWeightG: 30,
      printDuration: const Duration(minutes: 20),
    ),
  ];

  final materials = [
    material('m1', 'PLA Red', remainingWeight: 200, autoDeductEnabled: false),
    material('m2', 'PLA Blue', remainingWeight: 25, autoDeductEnabled: true),
  ];

  testWidgets('batch-wide selection updates state', (tester) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('PLA Red'));
    await tester.pumpAndSettle();

    expect(notifier.state.batchMaterialId, 'm1');
  });

  testWidgets(
    'empty material step creates and selects material without losing batch',
    (tester) async {
      final notifier = _FakeBatchCostingNotifier(items);
      await tester.pumpApp(const BatchMaterialAssignmentPage(), [
        batchCostingProvider.overrideWith(() => notifier),
        isPremiumProvider.overrideWithValue(false),
      ]);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('batch-create-material')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('batch-create-material')));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialForm), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(notifier.state.batchMaterialId, isNull);
      expect(notifier.state.items.length, 2);

      await tester.tap(find.byKey(const ValueKey('batch-create-material')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('settings.materials.name.input')),
        'New PLA',
      );
      await tester.enterText(
        find.byKey(const ValueKey('settings.materials.color.input')),
        'Blue',
      );
      await tester.enterText(
        find.byKey(const ValueKey('settings.materials.weight.input')),
        '500',
      );
      await tester.enterText(
        find.byKey(const ValueKey('settings.materials.cost.input')),
        '20',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('settings.materials.save.button')),
      );
      await tester.tap(
        find.byKey(const ValueKey('settings.materials.save.button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BatchMaterialAssignmentPage), findsOneWidget);
      expect(find.text('New PLA'), findsOneWidget);
      expect(notifier.state.batchMaterialId, isNotNull);
      expect(notifier.state.items.map((item) => item.displayName), [
        'Benchy',
        'Cube',
      ]);
      expect(
        notifier.state.itemMaterialAllocations['item-1']?.single.quantity,
        2,
      );
    },
  );

  testWidgets('free material quota disables in-batch creation', (tester) async {
    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => _FakeBatchCostingNotifier(items)),
      isPremiumProvider.overrideWithValue(false),
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value([
          for (var index = 0; index < 5; index++)
            material(
              'm$index',
              'Material $index',
              remainingWeight: 500,
              autoDeductEnabled: false,
            ),
        ]),
      ),
    ]);
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchMaterialAssignmentPage)),
    )!;
    expect(find.text(l10n.materialLimitReachedMessage), findsOneWidget);
    expect(
      tester
          .widget<AppSecondaryButton>(
            find.byKey(const ValueKey('batch-create-material')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('per-item mode uses reusable picker', (tester) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchMaterialAssignmentPage)),
    )!;
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<BatchMaterialAssignmentMode>),
        matching: find.text(l10n.batchCostingMaterialAssignmentPerItemMode),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(l10n.batchCostingAssignmentSplitCopiesButton),
      findsNWidgets(2),
    );
    await tester.tap(
      find.text(l10n.batchCostingAssignmentSplitCopiesButton).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('PLA Red'), findsOneWidget);
  });

  testWidgets('per-item cards hide placeholder and show selected rows', (
    tester,
  ) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchMaterialAssignmentPage)),
    )!;
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<BatchMaterialAssignmentMode>),
        matching: find.text(l10n.batchCostingMaterialAssignmentPerItemMode),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialAllocationRow), findsNothing);
    expect(find.text('×1'), findsNothing);

    notifier.setItemMaterialAllocations('item-1', [
      const BatchAssignmentAllocation(targetId: 'm1', quantity: 1),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(MaterialAllocationRow), findsNWidgets(1));
    expect(find.text('PLA Red'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
  });

  testWidgets('split material cards show multiple removable rows', (
    tester,
  ) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    notifier.setMaterialAssignmentMode(BatchMaterialAssignmentMode.perItem);
    notifier.setItemMaterialAllocations('item-1', [
      const BatchAssignmentAllocation(targetId: 'm1', quantity: 1),
      const BatchAssignmentAllocation(targetId: 'm2', quantity: 1),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(MaterialAllocationRow), findsNWidgets(2));
    expect(find.text('PLA Red'), findsOneWidget);
    expect(find.text('PLA Blue'), findsOneWidget);
    expect(find.text('×1'), findsNWidgets(2));
    expect(find.byIcon(Icons.remove_circle_outline), findsNWidgets(2));
  });

  testWidgets('stock warning appears and continue still works', (tester) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('PLA Blue'));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchMaterialAssignmentPage)),
    )!;
    expect(
      find.text(
        l10n.batchCostingMaterialAssignmentStockWarning(
          formatWeight(70),
          formatWeight(25),
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(BatchPricingScopePage), findsOneWidget);
  });

  testWidgets('free users continue directly to summary', (tester) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(false),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('PLA Red'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(BatchSummaryPage), findsOneWidget);
    expect(find.byType(BatchPricingScopePage), findsNothing);
  });
}

MaterialModel material(
  String id,
  String name, {
  required double remainingWeight,
  required bool autoDeductEnabled,
}) => MaterialModel(
  id: id,
  name: name,
  cost: '20',
  color: 'Natural',
  weight: '500',
  archived: false,
  autoDeductEnabled: autoDeductEnabled,
  originalWeight: 500,
  remainingWeight: remainingWeight,
);

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);
  final List<BatchCostingItem> _items;
  @override
  BatchCostingState build() => BatchCostingState(items: _items);
}
