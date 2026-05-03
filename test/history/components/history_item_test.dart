import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/components/history_item.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

import '../../helpers/helpers.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._settings);

  final GeneralSettingsModel _settings;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;

  @override
  Stream<GeneralSettingsModel> watchSettings() async* {
    yield _settings;
  }

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {}
}

void main() {
  setUpAll(() async {
    await setupTest();
  });

  testWidgets('formats final price with currency settings', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final db = await tester.pumpApp(
      HistoryItem(
        dbKey: 'history-1',
        data: HistoryModel(
          name: 'Test job',
          totalCost: 10,
          riskCost: 0.75,
          filamentCost: 2.5,
          electricityCost: 1.25,
          labourCost: 3.25,
          date: DateTime(2026, 1, 1),
          printer: 'Printer',
          material: 'PLA',
          weight: 100,
          timeHours: '01:00',
          pricingMarkupPercent: 25,
          pricingMarkupAmount: 2.5,
          pricingSetupFee: 1.25,
          pricingRoundingMode: 'wholeDollar',
          pricingSubtotalBeforeRounding: 13.75,
          pricingRoundingAdjustment: 0.25,
          finalPrice: 14,
        ),
      ),
      [
        settingsRepositoryProvider.overrideWithValue(
          _FakeSettingsRepository(
            const GeneralSettingsModel(
              electricityCost: '',
              wattage: '',
              activePrinter: '',
              selectedMaterial: '',
              wearAndTear: '',
              failureRisk: '',
              labourRate: '',
              pricingMarkupPercent: '',
              pricingSetupFee: '',
              pricingRoundingMode: 'none',
              currencySymbol: 'R',
              currencyPosition: 'before',
              currencySpacing: false,
            ),
          ),
        ),
      ],
    );
    addTearDown(() => db.close());

    await tester.pumpAndSettle();

    expect(find.text('R14.00'), findsOneWidget);
    expect(
      find.text(
        l10n.historySummaryLabel(
          l10n.historyWeightCompactLabel('0.10'),
          l10n.historyTimeCompactLabel('1', '0'),
          'Printer',
          'PLA',
        ),
      ),
      findsOneWidget,
    );
  });
}
