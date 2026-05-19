import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/history/components/history_item.dart';
import 'package:threed_print_cost_calculator/history/components/batch_history_item.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';

import '../../helpers/helpers.dart';

final HistoryModel _batchHistoryModel = HistoryModel(
  name: 'Test Batch',
  totalCost: 42.50,
  riskCost: 0,
  filamentCost: 0,
  electricityCost: 0,
  labourCost: 0,
  date: DateTime.utc(2024, 6, 15),
  printer: 'Unassigned',
  material: 'Unassigned',
  weight: 246,
  timeHours: '12:30',
  batchQuote: true,
  batchQuoteItems: const [
    {
      'id': 'item-1',
      'name': 'Part A',
      'quantity': 6,
      'totalWeightG': 150,
      'totalPrintDurationMinutes': 360,
      'baseCost': 15.00,
      'additionalCost': 0,
      'additionalCostNote': null,
      'finalTotal': 15.00,
    },
    {
      'id': 'item-2',
      'name': 'Part B',
      'quantity': 6,
      'totalWeightG': 96,
      'totalPrintDurationMinutes': 390,
      'baseCost': 27.50,
      'additionalCost': 0,
      'additionalCostNote': null,
      'finalTotal': 27.50,
    },
  ],
  batchQuoteSummary: const {
    'itemCount': 2,
    'totalQuantity': 12,
    'totalWeightG': 246,
    'totalPrintDurationMinutes': 750,
    'finalTotal': 42.50,
    'pricing': {
      'failureRisk': {'value': '10.0 %', 'scope': 'batch'},
      'markupPercent': {'value': '20.0 %', 'scope': 'batch'},
      'labourRate': {'value': '5.00', 'scope': 'item'},
      'additionalCostAmount': {'value': '0', 'scope': 'item'},
    },
  },
);

final GeneralSettingsModel _usdSettings = GeneralSettingsModel.initial().copyWith(
  currencySymbol: r'$',
  currencyPosition: 'before',
  currencySpacing: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setupTest);

  testWidgets('shows batch summary line with item count and total quantity', (
    tester,
  ) async {
    await tester.pumpApp(
      HistoryItem(dbKey: 'batch-1', data: _batchHistoryModel),
      [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(_usdSettings),
        ),
      ],
    );

    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchHistoryItem)),
    )!;
    final expectedLine = l10n.batchHistorySummaryLine(2, 12);
    expect(find.text(expectedLine), findsOneWidget);
  });

  testWidgets('shows total cost in currency format', (tester) async {
    await tester.pumpApp(
      HistoryItem(dbKey: 'batch-1', data: _batchHistoryModel),
      [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(_usdSettings),
        ),
      ],
    );

    await tester.pumpAndSettle();

    expect(find.text(r'$42.50'), findsOneWidget);
  });

  testWidgets('shows weight and duration', (tester) async {
    await tester.pumpApp(
      HistoryItem(dbKey: 'batch-1', data: _batchHistoryModel),
      [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(_usdSettings),
        ),
      ],
    );

    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchHistoryItem)),
    )!;
    expect(find.text('246.00 ${l10n.gramsSuffix}'), findsOneWidget);
    expect(find.text('12:30'), findsOneWidget);
  });

  testWidgets('pricing expansion tile shows non-zero pricing entries', (
    tester,
  ) async {
    await tester.pumpApp(
      HistoryItem(dbKey: 'batch-1', data: _batchHistoryModel),
      [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(_usdSettings),
        ),
      ],
    );

    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchHistoryItem)),
    )!;

    await tester.tap(find.text(l10n.batchCostingSummaryPricingTitle));
    await tester.pumpAndSettle();

    expect(find.textContaining('10.0'), findsOneWidget);
    expect(find.textContaining('20.0'), findsOneWidget);
    expect(find.textContaining('5.00'), findsOneWidget);
    // additionalCostAmount has value '0' and should not appear
    expect(find.textContaining(l10n.additionalCostLabel), findsNothing);
  });

  testWidgets('falls back to items data when batchQuoteSummary is null', (
    tester,
  ) async {
    final modelWithoutSummary = HistoryModel(
      name: 'Legacy Batch',
      totalCost: 10.00,
      riskCost: 0,
      filamentCost: 0,
      electricityCost: 0,
      labourCost: 0,
      date: DateTime.utc(2024, 1, 1),
      printer: 'Unassigned',
      material: 'Unassigned',
      weight: 50,
      timeHours: '02:00',
      batchQuote: true,
      batchQuoteItems: const [
        {'name': 'Widget', 'quantity': 3},
        {'name': 'Gadget', 'quantity': 5},
      ],
      batchQuoteSummary: null,
    );

    await tester.pumpApp(
      HistoryItem(dbKey: 'legacy-batch', data: modelWithoutSummary),
      [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(_usdSettings),
        ),
      ],
    );

    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchHistoryItem)),
    )!;
    // 2 unique names → itemCount=2, 3+5=8 → totalQuantity=8
    final expectedLine = l10n.batchHistorySummaryLine(2, 8);
    expect(find.text(expectedLine), findsOneWidget);
  });

  testWidgets('items expansion tile shows item details', (tester) async {
    await tester.pumpApp(
      HistoryItem(dbKey: 'batch-1', data: _batchHistoryModel),
      [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(_usdSettings),
        ),
      ],
    );

    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchHistoryItem)),
    )!;

    await tester.tap(find.text(l10n.batchHistoryItemsTitle));
    await tester.pumpAndSettle();

    expect(find.textContaining('Part A × 6'), findsOneWidget);
    expect(find.textContaining('Part B × 6'), findsOneWidget);
    expect(find.textContaining(r'$15.00'), findsNWidgets(2));
    expect(find.textContaining(r'$27.50'), findsAtLeastNWidgets(1));
  });
}
