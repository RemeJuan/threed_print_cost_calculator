import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
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

  testWidgets('defaults to batch-wide mode', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    expect(
      notifier.state.materialAssignmentMode,
      BatchMaterialAssignmentMode.batchWide,
    );
  });

  testWidgets('batch-wide selection updates state', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    await tester.tap(find.byType(BatchAnchorSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PLA Red').last);
    await tester.pumpAndSettle();

    expect(notifier.state.batchMaterialId, 'm1');
    expect(
      notifier.state.items.every((item) => item.materialId == 'm1'),
      isTrue,
    );
  });

  testWidgets('per-item mode shows one selector per batch item', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    tester
        .widget<SegmentedButton<BatchMaterialAssignmentMode>>(
          find.byType(SegmentedButton<BatchMaterialAssignmentMode>),
        )
        .onSelectionChanged
        ?.call({BatchMaterialAssignmentMode.perItem});
    await tester.pumpAndSettle();

    expect(find.text('Benchy'), findsOneWidget);
    expect(find.text('Cube'), findsOneWidget);
    expect(find.byType(BatchAnchorSelector), findsNWidgets(2));
  });

  testWidgets('missing per-item selection blocks continue', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    tester
        .widget<SegmentedButton<BatchMaterialAssignmentMode>>(
          find.byType(SegmentedButton<BatchMaterialAssignmentMode>),
        )
        .onSelectionChanged
        ?.call({BatchMaterialAssignmentMode.perItem});
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchMaterialAssignmentPage)),
    )!;
    expect(
      find.text(l10n.batchCostingMaterialAssignmentRequiredError),
      findsWidgets,
    );
  });

  testWidgets('stock warning appears and continue still works', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    await tester.tap(find.byType(BatchAnchorSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PLA Blue').last);
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

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(BatchPricingScopePage), findsOneWidget);
  });

  testWidgets('disabled feature prevents access', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpApp(const BatchMaterialAssignmentPage(), [
      isPremiumProvider.overrideWithValue(false),
    ]);

    expect(find.text('Material assignment'), findsNothing);
  });
}

MaterialModel material(
  String id,
  String name, {
  required double remainingWeight,
  required bool autoDeductEnabled,
}) {
  return MaterialModel(
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
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);

  final List<BatchCostingItem> _items;

  @override
  BatchCostingState build() => BatchCostingState(items: _items);
}
