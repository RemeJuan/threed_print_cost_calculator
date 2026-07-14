import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_faq_entries.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import '../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('buildHelpSupportFaqEntries preserves order and callbacks', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    var premiumActionCalls = 0;
    var premiumLinkCalls = 0;

    final freeEntries = buildHelpSupportFaqEntries(
      l10n,
      isPremium: false,
      onPremiumActionTap: () => premiumActionCalls++,
      onPremiumLinkTap: () => premiumLinkCalls++,
    );

    expect(freeEntries.map((entry) => entry.id), [
      'premium',
      'weight',
      'electricity',
      'wattage',
      'risk',
      'labour',
      'markup',
      'setup',
    ]);
    expect(freeEntries.first.question, l10n.helpSupportFaqPremiumQuestion);
    expect(freeEntries.first.answer, l10n.helpSupportFaqPremiumAnswer);
    expect(freeEntries.first.actionLabel, l10n.helpSupportFaqPremiumUpgradeCta);
    expect(
      freeEntries.first.linkLabel,
      l10n.helpSupportFaqPremiumComparisonCta,
    );
    freeEntries.first.onActionTap?.call();
    freeEntries.first.onLinkTap?.call();
    expect(premiumActionCalls, 1);
    expect(premiumLinkCalls, 1);

    expect(freeEntries[1].question, l10n.helpSupportFaqWeightQuestion);
    expect(freeEntries[1].answer, l10n.helpSupportFaqWeightAnswer);
    expect(freeEntries[2].question, l10n.helpSupportFaqElectricityQuestion);
    expect(freeEntries[2].answer, l10n.helpSupportFaqElectricityAnswer);
    expect(freeEntries[3].question, l10n.helpSupportFaqWattageQuestion);
    expect(freeEntries[3].answer, l10n.helpSupportFaqWattageAnswer);
    expect(freeEntries[4].question, l10n.helpSupportFaqRiskQuestion);
    expect(freeEntries[4].answer, l10n.helpSupportFaqRiskAnswer);
    expect(freeEntries[5].question, l10n.helpSupportFaqLabourQuestion);
    expect(freeEntries[5].answer, l10n.helpSupportFaqLabourAnswer);
    expect(freeEntries[6].question, l10n.helpSupportFaqMarkupQuestion);
    expect(freeEntries[6].answer, l10n.helpSupportFaqMarkupAnswer);
    expect(freeEntries[7].question, l10n.helpSupportFaqSetupQuestion);
    expect(freeEntries[7].answer, l10n.helpSupportFaqSetupAnswer);

    final premiumEntries = buildHelpSupportFaqEntries(
      l10n,
      isPremium: true,
      onPremiumActionTap: () => premiumActionCalls++,
      onPremiumLinkTap: () => premiumLinkCalls++,
    );

    expect(premiumEntries.first.actionLabel, isNull);
    expect(premiumEntries.first.onActionTap, isNull);
    expect(premiumEntries.first.onLinkTap, isNotNull);
  });
}
