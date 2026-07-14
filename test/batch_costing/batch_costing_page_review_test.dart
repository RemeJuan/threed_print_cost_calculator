import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

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

  testWidgets(
    'free populated batch shows manual action and hides import labels',
    (tester) async {
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
          () => FakeBatchCostingNotifier([item]),
        ),
        isPremiumProvider.overrideWithValue(false),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: false),
        ),
      ]);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchCostingPage)),
      )!;

      expect(
        find.text(l10n.batchCostingReviewAddManualItemButton),
        findsOneWidget,
      );
      expect(find.text(l10n.batchCostingReviewImportGcodeButton), findsNothing);
      expect(
        find.text('${l10n.batchCostingReviewImportGcodeButton} (Premium)'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'premium populated batch shows header import and manual actions',
    (tester) async {
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
          () => FakeBatchCostingNotifier([item]),
        ),
        isPremiumProvider.overrideWithValue(true),
      ]);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchCostingPage)),
      )!;

      expect(
        find.text(l10n.batchCostingReviewAddManualItemButton),
        findsOneWidget,
      );
      expect(
        find.text(l10n.batchCostingReviewImportGcodeButton),
        findsOneWidget,
      );
    },
  );

  testWidgets('footer disables continue when batch item missing fields', (
    tester,
  ) async {
    final item = BatchCostingItem.fromGCodeImport(
      id: 'item-1',
      displayName: 'Benchy',
      quantity: 2,
      sourceFileName: 'benchy.gcode',
      importResult: const GCodeImportResult(
        slicer: GCodeSlicer.unknown,
        estimatedDuration: Duration(hours: 1, minutes: 20),
        filamentLengthMm: 1000,
        filamentWeightG: null,
        layerHeightMm: 0.2,
        previewMetadata: null,
        previewImageBytes: null,
        warnings: <GCodeParseWarning>[],
        rawExtractedValues: <String, String>{},
      ),
    );

    await tester.pumpApp(const BatchCostingPage(), [
      batchCostingProvider.overrideWith(() => FakeBatchCostingNotifier([item])),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchCostingPage)),
    )!;

    final continueButton = tester.widget<AppPrimaryButton>(
      find.widgetWithText(
        AppPrimaryButton,
        l10n.batchCostingReviewContinueButton,
      ),
    );

    expect(continueButton.onPressed, isNull);
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
