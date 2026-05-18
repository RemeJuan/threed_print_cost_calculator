import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  testWidgets('hides the batch review when disabled', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpApp(const BatchCostingPage(), [
      isPremiumProvider.overrideWithValue(false),
    ]);

    expect(find.text('Batch item review'), findsNothing);
    expect(find.text('No batch items yet'), findsNothing);
  });

  testWidgets('shows review items and removes them', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

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

    await tester.tap(find.text('Benchy'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchCostingReviewRemoveButton), findsOneWidget);

    await tester.tap(find.text(l10n.batchCostingReviewRemoveButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchCostingReviewEmptyTitle), findsOneWidget);
    expect(find.text('Benchy'), findsNothing);
  });

  testWidgets('adds edits and removes manual items', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

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

    await tester.tap(find.text('Benchy'));
    await tester.pumpAndSettle();

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
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

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

    await tester.tap(find.text('Benchy'));
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
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);

  final List<BatchCostingItem> _items;

  @override
  BatchCostingState build() {
    return BatchCostingState(items: _items);
  }
}
