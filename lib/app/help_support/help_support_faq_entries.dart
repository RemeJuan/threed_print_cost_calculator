import 'package:flutter/foundation.dart';
import 'package:threed_print_cost_calculator/app/help_support/models/help_support_faq_entry.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

export 'package:threed_print_cost_calculator/app/help_support/models/help_support_faq_entry.dart';

const helpSupportPremiumFaqEntryId = 'premium';

List<HelpSupportFaqEntry> buildHelpSupportFaqEntries(
  AppLocalizations l10n, {
  required bool isPremium,
  required VoidCallback onPremiumActionTap,
  required VoidCallback onPremiumLinkTap,
}) {
  return [
    HelpSupportFaqEntry(
      id: helpSupportPremiumFaqEntryId,
      question: l10n.helpSupportFaqPremiumQuestion,
      answer: l10n.helpSupportFaqPremiumAnswer,
      actionLabel: isPremium ? null : l10n.helpSupportFaqPremiumUpgradeCta,
      onActionTap: isPremium ? null : onPremiumActionTap,
      linkLabel: l10n.helpSupportFaqPremiumComparisonCta,
      onLinkTap: onPremiumLinkTap,
    ),
    HelpSupportFaqEntry(
      id: 'weight',
      question: l10n.helpSupportFaqWeightQuestion,
      answer: l10n.helpSupportFaqWeightAnswer,
    ),
    HelpSupportFaqEntry(
      id: 'electricity',
      question: l10n.helpSupportFaqElectricityQuestion,
      answer: l10n.helpSupportFaqElectricityAnswer,
    ),
    HelpSupportFaqEntry(
      id: 'wattage',
      question: l10n.helpSupportFaqWattageQuestion,
      answer: l10n.helpSupportFaqWattageAnswer,
    ),
    HelpSupportFaqEntry(
      id: 'risk',
      question: l10n.helpSupportFaqRiskQuestion,
      answer: l10n.helpSupportFaqRiskAnswer,
    ),
    HelpSupportFaqEntry(
      id: 'labour',
      question: l10n.helpSupportFaqLabourQuestion,
      answer: l10n.helpSupportFaqLabourAnswer,
    ),
    HelpSupportFaqEntry(
      id: 'markup',
      question: l10n.helpSupportFaqMarkupQuestion,
      answer: l10n.helpSupportFaqMarkupAnswer,
    ),
    HelpSupportFaqEntry(
      id: 'setup',
      question: l10n.helpSupportFaqSetupQuestion,
      answer: l10n.helpSupportFaqSetupAnswer,
    ),
  ];
}
