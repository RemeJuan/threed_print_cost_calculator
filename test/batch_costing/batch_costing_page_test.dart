import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  testWidgets('hides the batch review when disabled', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpApp(const BatchCostingPage());

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
      batchCostingProvider.overrideWith(() => _FakeBatchCostingNotifier(item)),
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
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._item);

  final BatchCostingItem _item;

  @override
  BatchCostingState build() {
    return BatchCostingState(items: [_item]);
  }
}
