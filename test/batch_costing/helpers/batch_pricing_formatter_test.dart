import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_pricing_formatter.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

import '../../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  const settings = GeneralSettingsModel(
    electricityCost: '',
    wattage: '',
    activePrinter: '',
    selectedMaterial: '',
    wearAndTear: '',
    failureRisk: '',
    labourRate: '',
    currencySymbol: '',
    currencyPosition: 'before',
    currencySpacing: false,
  );

  testWidgets('empty and invalid input', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpApp(
      Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox.shrink();
        },
      ),
    );

    expect(
      formatPricingSummary('', BatchPricingScope.batch, 1, l10n, settings),
      '',
    );
    expect(
      formatPricingSummary('bad', BatchPricingScope.batch, 1, l10n, settings),
      '0.00',
    );
  });

  testWidgets('comma decimals, scope, percent, multiplier', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpApp(
      Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox.shrink();
        },
      ),
    );

    expect(
      formatPricingSummary('12,5', BatchPricingScope.batch, 3, l10n, settings),
      '12.50',
    );
    expect(
      formatPricingSummary('12,5', BatchPricingScope.item, 3, l10n, settings),
      '12.50 each → 37.50 total',
    );
    expect(
      formatPricingSummary(
        '10',
        BatchPricingScope.batch,
        2,
        l10n,
        settings,
        isPercent: true,
        monetaryImpact: 7.5,
      ),
      '10% → 7.50',
    );
    expect(
      formatPricingSummary(
        '10',
        BatchPricingScope.item,
        2,
        l10n,
        settings,
        isPercent: true,
        monetaryImpact: 7.5,
      ),
      '10% each → 7.50 total',
    );
  });
}
