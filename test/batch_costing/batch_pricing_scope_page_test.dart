import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

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
  ];

  testWidgets('defaults to expected pricing scopes', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPricingScopePage(), [
      batchCostingProvider.overrideWith(() => notifier),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    expect(notifier.state.pricing.failureRisk.scope, BatchPricingScope.item);
    expect(notifier.state.pricing.markupPercent.scope, BatchPricingScope.item);
    expect(notifier.state.pricing.labourRate.scope, BatchPricingScope.item);
    expect(
      notifier.state.pricing.additionalCostAmount.scope,
      BatchPricingScope.batch,
    );
  });

  testWidgets('scope can change per field', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPricingScopePage(), [
      batchCostingProvider.overrideWith(() => notifier),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    final scopeFields = find.byType(DropdownButtonFormField<BatchPricingScope>);
    expect(scopeFields, findsNWidgets(4));

    tester.widget<DropdownButtonFormField<BatchPricingScope>>(scopeFields.at(0)).onChanged?.call(
      BatchPricingScope.batch,
    );
    tester.widget<DropdownButtonFormField<BatchPricingScope>>(scopeFields.at(1)).onChanged?.call(
      BatchPricingScope.batch,
    );
    tester.widget<DropdownButtonFormField<BatchPricingScope>>(scopeFields.at(2)).onChanged?.call(
      BatchPricingScope.batch,
    );
    tester.widget<DropdownButtonFormField<BatchPricingScope>>(scopeFields.at(3)).onChanged?.call(
      BatchPricingScope.item,
    );

    await tester.pumpAndSettle();

    expect(notifier.state.pricing.failureRisk.scope, BatchPricingScope.batch);
    expect(notifier.state.pricing.markupPercent.scope, BatchPricingScope.batch);
    expect(notifier.state.pricing.labourRate.scope, BatchPricingScope.batch);
    expect(
      notifier.state.pricing.additionalCostAmount.scope,
      BatchPricingScope.item,
    );
  });

  testWidgets('invalid values block continue', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPricingScopePage(), [
      batchCostingProvider.overrideWith(() => notifier),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).at(0), '120');
    await tester.enterText(find.byType(EditableText).at(1), '10');
    await tester.enterText(find.byType(EditableText).at(2), '10');
    await tester.enterText(find.byType(EditableText).at(3), '10');

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchPricingScopePage)),
    )!;
    expect(find.text(l10n.invalidNumber), findsOneWidget);
    expect(find.byType(BatchPricingScopePage), findsOneWidget);
  });

  testWidgets('valid values allow continue and preserve state', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPricingScopePage(), [
      batchCostingProvider.overrideWith(() => notifier),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).at(0), '10');
    await tester.enterText(find.byType(EditableText).at(1), '20');
    await tester.enterText(find.byType(EditableText).at(2), '30');
    await tester.enterText(find.byType(EditableText).at(3), '40');

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(BatchSummaryPage), findsOneWidget);
    expect(notifier.state.pricing.failureRisk.value, '10');
    expect(notifier.state.pricing.markupPercent.value, '20');
    expect(notifier.state.pricing.labourRate.value, '30');
    expect(notifier.state.pricing.additionalCostAmount.value, '40');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(BatchPricingScopePage), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText).at(0)).controller.text,
      '10',
    );
  });

  testWidgets('disabled feature prevents access', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpApp(const BatchPricingScopePage(), [
      isPremiumProvider.overrideWithValue(false),
    ]);

    expect(find.text('Pricing scope'), findsNothing);
  });
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);

  final List<BatchCostingItem> _items;

  @override
  BatchCostingState build() => BatchCostingState(items: _items);
}
