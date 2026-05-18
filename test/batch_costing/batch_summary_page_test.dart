import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  testWidgets('hides when batch costing is disabled', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpApp(const BatchSummaryPage());

    expect(find.text('Batch summary'), findsNothing);
  });

  testWidgets('shows empty state with back action when no items', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

    await tester.pumpApp(const BatchSummaryPage(), [
      batchCostingProvider.overrideWith(() => _EmptyBatchCostingNotifier()),
    ]);

    expect(find.text('No batch summary yet'), findsOneWidget);
    expect(find.text('Back to pricing scope'), findsOneWidget);
  });

  testWidgets('shows calculated totals and item breakdown', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

    await tester.pumpApp(const BatchSummaryPage(), [
      batchCostingProvider.overrideWith(() => _SummaryBatchCostingNotifier()),
    ]);

    final l10n = AppLocalizations.of(tester.element(find.byType(BatchSummaryPage)))!;

    expect(find.text('1'), findsWidgets);
    expect(find.text('2'), findsWidgets);
    expect(find.text('20.00 g'), findsOneWidget);
    expect(find.text('02:00'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('27.00'), 200);
    await tester.pumpAndSettle();

    expect(find.text('27.00'), findsOneWidget);

    await tester.tap(find.text('Benchy'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchCostingSummaryItemBaseCostLabel), findsOneWidget);
    expect(find.text(l10n.batchCostingSummaryItemAdjustmentLabel), findsOneWidget);
    expect(find.text(l10n.batchCostingSummaryItemTotalLabel), findsOneWidget);
  });
}

class _EmptyBatchCostingNotifier extends BatchCostingNotifier {
  @override
  BatchCostingState build() => BatchCostingState();
}

class _SummaryBatchCostingNotifier extends BatchCostingNotifier {
  @override
  BatchCostingState build() {
    return BatchCostingState(
      items: [
        BatchCostingItem.manual(
          id: 'item-1',
          displayName: 'Benchy',
          quantity: 2,
          printWeightG: 10,
          printDuration: const Duration(hours: 1),
        ),
      ],
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
    );
  }
}
