import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

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

  testWidgets(
    'pricing explains absent item labour and previews setup cost as rate changes',
    (tester) async {
      final notifier = _FakeBatchCostingNotifier(items);
      await tester.pumpApp(const BatchPricingScopePage(), [
        batchCostingProvider.overrideWith(() => notifier),
        isPremiumProvider.overrideWithValue(true),
      ]);
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchPricingScopePage)),
      )!;
      expect(find.text(l10n.batchCostingLabourRateHelp), findsOneWidget);
      expect(find.text(l10n.batchCostingNoLabourTimeEntered), findsOneWidget);
      expect(
        find.text(l10n.batchCostingSetupLabourCostPreview('0.00')),
        findsOneWidget,
      );
      await tester.enterText(find.byType(EditableText).at(3), '60');
      await tester.enterText(
        find.byKey(const ValueKey('batch-setup-labour-minutes')),
        '15',
      );
      await tester.pump();
      expect(
        find.text(l10n.batchCostingSetupLabourCostPreview('15.00')),
        findsOneWidget,
      );
      await tester.enterText(find.byType(EditableText).at(3), '120');
      await tester.pump();
      expect(
        find.text(l10n.batchCostingSetupLabourCostPreview('30.00')),
        findsOneWidget,
      );
    },
  );

  testWidgets('pricing hides no-labour notice when item minutes exist', (
    tester,
  ) async {
    final notifier = _FakeBatchCostingNotifier([
      items.single.copyWith(itemLabourMinutes: 5),
    ]);
    await tester.pumpApp(const BatchPricingScopePage(), [
      batchCostingProvider.overrideWith(() => notifier),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchPricingScopePage)),
    )!;
    expect(find.text(l10n.batchCostingNoLabourTimeEntered), findsNothing);
  });

  testWidgets('defaults to expected pricing scopes', (tester) async {
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

  testWidgets('scope selectors precede labour fields and setup aligns', (
    tester,
  ) async {
    await tester.pumpApp(const BatchPricingScopePage(), [
      batchCostingProvider.overrideWith(() => _FakeBatchCostingNotifier(items)),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchPricingScopePage)),
    )!;
    final pricingFields = tester
        .widgetList<FocusSafeTextField>(find.byType(FocusSafeTextField))
        .map((field) => (field.decoration!.label! as Text).data)
        .toList();
    expect(pricingFields, [
      l10n.failureRiskLabel,
      l10n.pricingMarkupPercentLabel,
      l10n.additionalCostLabel,
      l10n.batchCostingHourlyLabourRateLabel,
    ]);

    final setup = find.byKey(const ValueKey('batch-setup-labour-minutes'));
    await tester.ensureVisible(setup);
    await tester.pumpAndSettle();
    final labour = find.byType(FocusSafeTextField).at(3);
    final labourCard = find.ancestor(
      of: labour,
      matching: find.byType(AppSurfaceCard),
    );
    final setupCard = find.ancestor(
      of: setup,
      matching: find.byType(AppSurfaceCard),
    );
    expect(tester.getTopLeft(setupCard).dx, tester.getTopLeft(labourCard).dx);
    expect(
      tester.getTopLeft(setup).dx,
      tester
          .getTopLeft(
            find.descendant(of: labour, matching: find.byType(TextFormField)),
          )
          .dx,
    );
  });

  testWidgets('scope can change per field', (tester) async {
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPricingScopePage(), [
      batchCostingProvider.overrideWith(() => notifier),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    final scopeFields = find.byType(SegmentedButton<BatchPricingScope>);
    expect(scopeFields, findsNWidgets(3));

    tester
        .widget<SegmentedButton<BatchPricingScope>>(scopeFields.at(0))
        .onSelectionChanged
        ?.call({BatchPricingScope.batch});
    tester
        .widget<SegmentedButton<BatchPricingScope>>(scopeFields.at(1))
        .onSelectionChanged
        ?.call({BatchPricingScope.batch});
    tester
        .widget<SegmentedButton<BatchPricingScope>>(scopeFields.at(2))
        .onSelectionChanged
        ?.call({BatchPricingScope.item});

    await tester.pumpAndSettle();

    expect(notifier.state.pricing.failureRisk.scope, BatchPricingScope.batch);
    expect(notifier.state.pricing.markupPercent.scope, BatchPricingScope.batch);
    expect(
      notifier.state.pricing.additionalCostAmount.scope,
      BatchPricingScope.item,
    );
  });

  testWidgets('invalid values block continue', (tester) async {
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

    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchPricingScopePage)),
    )!;
    expect(find.text(l10n.invalidNumber), findsOneWidget);
    expect(find.byType(BatchPricingScopePage), findsOneWidget);
  });

  testWidgets('valid values allow continue and preserve state', (tester) async {
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPricingScopePage(), [
      batchCostingProvider.overrideWith(() => notifier),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).at(0), '10');
    await tester.enterText(find.byType(EditableText).at(1), '20');
    await tester.enterText(find.byType(EditableText).at(2), '40');
    await tester.enterText(find.byType(EditableText).at(3), '30');
    await tester.enterText(
      find.byKey(const ValueKey('batch-setup-labour-minutes')),
      '15',
    );

    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(BatchSummaryPage), findsOneWidget);
    expect(notifier.state.pricing.failureRisk.value, '10');
    expect(notifier.state.pricing.markupPercent.value, '20');
    expect(notifier.state.pricing.labourRate.value, '30');
    expect(notifier.state.pricing.additionalCostAmount.value, '40');
    expect(notifier.state.setupLabourMinutes, 15);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(BatchPricingScopePage), findsOneWidget);
    expect(
      find.byKey(const ValueKey('batch-setup-labour-minutes')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).at(0))
          .controller
          .text,
      '10',
    );
  });
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);

  final List<BatchCostingItem> _items;

  @override
  BatchCostingState build() => BatchCostingState(items: _items);
}
