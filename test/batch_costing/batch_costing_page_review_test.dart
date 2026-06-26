import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart';
import 'batch_costing_page_test_support.dart';

void main() {
  setUpAll(setupTest);

  testWidgets('shows review items and removes them', (tester) async {
    final item = BatchCostingItem.manual(
      id: 'item-1',
      displayName: 'Benchy',
      quantity: 2,
      printWeightG: 34.5,
      printDuration: const Duration(hours: 1, minutes: 20),
      sourceFileName: 'benchy.gcode',
    );

    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(() => FakeBatchCostingNotifier([item])),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    expect(find.text(l10n.batchCostingReviewAppBarTitle), findsOneWidget);
    expect(find.text('Benchy'), findsOneWidget);
    expect(find.text(l10n.batchCostingReviewContinueButton), findsOneWidget);

    expect(find.text(l10n.batchCostingReviewRemoveButton), findsOneWidget);

    await tester.tap(find.text(l10n.batchCostingReviewRemoveButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchCostingReviewEmptyTitle), findsOneWidget);
    expect(find.text('Benchy'), findsNothing);
  });

  testWidgets('free users do not see batch gcode import button', (
    tester,
  ) async {
    final paywallPresenter = FakePaywallPresenter();

    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(
        () => FakeBatchCostingNotifier(const <BatchCostingItem>[]),
      ),
      isPremiumProvider.overrideWithValue(false),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      premiumAccessPolicyProvider.overrideWithValue(
        DefaultPremiumAccessPolicy(isPremium: false),
      ),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    expect(find.text(l10n.batchCostingReviewEmptyBody), findsOneWidget);
    expect(
      find.text('${l10n.batchCostingReviewImportGcodeButton} (Premium)'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('${l10n.batchCostingReviewImportGcodeButton} (Premium)'),
    );
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 1);
  });

  testWidgets('start new batch resets stack and returns home', (tester) async {
    const openBatchLabel = 'Open batch';

    final item = BatchCostingItem.manual(
      id: 'item-1',
      displayName: 'Benchy',
      quantity: 2,
      printWeightG: 34.5,
      printDuration: const Duration(hours: 1, minutes: 20),
      sourceFileName: 'benchy.gcode',
    );

    await tester.pumpApp(const BatchFlowHomeHarness(), [
      batchCostingProvider.overrideWith(() => FakeBatchCostingNotifier([item])),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.tap(find.text(openBatchLabel));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    expect(find.text('Benchy'), findsOneWidget);

    await tester.tap(find.text(l10n.batchCostingSummaryStartNewBatchButton));
    await tester.pumpAndSettle();

    await tester.tap(
      find.text(l10n.batchCostingSummaryStartNewBatchButton).last,
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchCostingReviewEmptyTitle), findsOneWidget);
    expect(find.byType(BatchCostingPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(openBatchLabel), findsOneWidget);
    expect(find.byType(BatchCostingPage), findsNothing);
  });
}
