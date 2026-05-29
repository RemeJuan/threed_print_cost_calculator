import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart';

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
      batchCostingProvider.overrideWith(
        () => _FakeBatchCostingNotifier([item]),
      ),
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
        () => _FakeBatchCostingNotifier(const <BatchCostingItem>[]),
      ),
      isPremiumProvider.overrideWithValue(false),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      premiumAccessPolicyProvider.overrideWithValue(
        DefaultPremiumAccessPolicy(isPremium: false, hideProPromotions: false),
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

    await tester.pumpApp(const _BatchFlowHomeHarness(), [
      batchCostingProvider.overrideWith(
        () => _FakeBatchCostingNotifier([item]),
      ),
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

  testWidgets('adds edits and removes manual items', (tester) async {
    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(
        () => _FakeBatchCostingNotifier(const <BatchCostingItem>[]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    await tester.tap(find.text(l10n.batchCostingReviewAddManualItemButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-name')),
      'Benchy',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
      '2',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-weight')),
      '34.5',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-hours')),
      '1',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-minutes')),
      '20',
    );
    await tester.tap(find.text(l10n.saveButton));
    await tester.pumpAndSettle();

    expect(find.text('Benchy'), findsOneWidget);

    await tester.tap(find.text(l10n.editButton).last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-name')),
      'Benchy v2',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
      '3',
    );
    await tester.tap(find.text(l10n.saveButton));
    await tester.pumpAndSettle();

    expect(find.text('Benchy v2'), findsOneWidget);

    await tester.tap(find.text(l10n.batchCostingReviewRemoveButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchCostingReviewEmptyTitle), findsOneWidget);
    expect(find.text(l10n.batchCostingReviewContinueButton), findsNothing);
  });

  testWidgets('validates add and edit forms', (tester) async {
    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(
        () => _FakeBatchCostingNotifier(const <BatchCostingItem>[]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    await tester.tap(find.text(l10n.batchCostingReviewAddManualItemButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.saveButton));
    await tester.pump();
    expect(find.text(l10n.csvNameRequiredError), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-name')),
      'Benchy',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
      '0',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-weight')),
      '0',
    );
    await tester.tap(find.text(l10n.saveButton));
    await tester.pump();
    expect(find.text(l10n.invalidNumber), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
      '1',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-weight')),
      '1',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-hours')),
      '0',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-minutes')),
      '1',
    );
    await tester.tap(find.text(l10n.saveButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.editButton).last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-name')),
      '',
    );
    await tester.tap(find.text(l10n.saveButton));
    await tester.pump();

    expect(find.text(l10n.csvNameRequiredError), findsOneWidget);
    expect(find.text('Benchy'), findsOneWidget);
  });

  testWidgets('defaults to 0 for numeric fields in add dialog', (tester) async {
    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(
        () => _FakeBatchCostingNotifier(const <BatchCostingItem>[]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    await tester.tap(find.text(l10n.batchCostingReviewAddManualItemButton));
    await tester.pumpAndSettle();

    final quantityField = tester.widget<TextFormField>(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
    );
    expect(quantityField.controller!.text, equals('0'));

    final weightField = tester.widget<TextFormField>(
      find.byKey(const ValueKey<String>('batch-costing-item-weight')),
    );
    expect(weightField.controller!.text, equals('0'));

    final hoursField = tester.widget<TextFormField>(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-hours')),
    );
    expect(hoursField.controller!.text, equals('0'));

    final minutesField = tester.widget<TextFormField>(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-minutes')),
    );
    expect(minutesField.controller!.text, equals('0'));
  });

  testWidgets('entering digit into defaulted 0 field replaces the 0', (
    tester,
  ) async {
    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(
        () => _FakeBatchCostingNotifier(const <BatchCostingItem>[]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    await tester.tap(find.text(l10n.batchCostingReviewAddManualItemButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
      '2',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-weight')),
      '34.5',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-hours')),
      '1',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-minutes')),
      '20',
    );

    final quantityField = tester.widget<TextFormField>(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
    );
    expect(quantityField.controller!.text, equals('2'));

    final weightField = tester.widget<TextFormField>(
      find.byKey(const ValueKey<String>('batch-costing-item-weight')),
    );
    expect(weightField.controller!.text, equals('34.5'));

    final hoursField = tester.widget<TextFormField>(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-hours')),
    );
    expect(hoursField.controller!.text, equals('1'));

    final minutesField = tester.widget<TextFormField>(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-minutes')),
    );
    expect(minutesField.controller!.text, equals('20'));

    await tester.tap(find.text(l10n.saveButton));
    await tester.pumpAndSettle();

    expect(find.text('Benchy'), findsNothing);
  });

  testWidgets('default 0 values block save', (tester) async {
    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(
        () => _FakeBatchCostingNotifier(const <BatchCostingItem>[]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    await tester.tap(find.text(l10n.batchCostingReviewAddManualItemButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-name')),
      'Benchy',
    );

    await tester.tap(find.text(l10n.saveButton));
    await tester.pump();

    expect(find.text(l10n.invalidNumber), findsWidgets);
  });

  testWidgets('valid input saves correctly from 0 defaults', (tester) async {
    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(
        () => _FakeBatchCostingNotifier(const <BatchCostingItem>[]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    await tester.tap(find.text(l10n.batchCostingReviewAddManualItemButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-name')),
      'Widget',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
      '3',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-weight')),
      '50',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-hours')),
      '0',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-minutes')),
      '15',
    );
    await tester.tap(find.text(l10n.saveButton));
    await tester.pumpAndSettle();

    expect(find.text('Widget'), findsOneWidget);

    await tester.tap(find.text(l10n.batchCostingReviewRemoveButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchCostingReviewEmptyTitle), findsOneWidget);
  });

  testWidgets('free users at batch item cap see quota message', (tester) async {
    final items = [
      for (var i = 1; i <= 3; i++)
        BatchCostingItem.manual(
          id: 'item-$i',
          displayName: 'Existing $i',
          quantity: 1,
          printWeightG: 10,
          printDuration: const Duration(minutes: 10),
        ),
    ];

    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(() => _FakeBatchCostingNotifier(items)),
      premiumAccessPolicyProvider.overrideWithValue(
        DefaultPremiumAccessPolicy(isPremium: false, hideProPromotions: false),
      ),
      isPremiumProvider.overrideWithValue(false),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    await tester.tap(find.text(l10n.batchCostingReviewAddManualItemButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-name')),
      'Blocked item',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-quantity')),
      '1',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-weight')),
      '10',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-hours')),
      '0',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('batch-costing-item-duration-minutes')),
      '10',
    );
    await tester.tap(find.text(l10n.saveButton));
    await tester.pumpAndSettle();

    expect(find.text('Blocked item'), findsNothing);
    expect(find.text(l10n.batchItemLimitReachedMessage), findsOneWidget);
  });
}

class _BatchFlowHomeHarness extends StatelessWidget {
  const _BatchFlowHomeHarness();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BatchCostingPage()),
          );
        },
        child: const Text('Open batch'),
      ),
    );
  }
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);

  final List<BatchCostingItem> _items;

  @override
  BatchCostingState build() {
    return BatchCostingState(items: _items);
  }
}
