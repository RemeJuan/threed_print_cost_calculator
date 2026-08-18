import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

String formatPricingSummary(
  String value,
  BatchPricingScope scope,
  int totalQuantity,
  AppLocalizations l10n,
  GeneralSettingsModel currencySettings, {
  bool isPercent = false,
  num monetaryImpact = 0,
}) {
  if (value.isEmpty) return '';
  final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0;

  if (isPercent) {
    final formattedValue = '$value%';
    final formattedImpact = monetaryImpact.toStringAsFixed(2);
    if (scope == BatchPricingScope.batch) {
      return '$formattedValue → $formattedImpact';
    }
    return l10n.batchCostingSummaryPricingItemScopeFormat(
      formattedImpact,
      formattedValue,
    );
  }

  final formattedValue = parsed.toStringAsFixed(2);
  if (scope == BatchPricingScope.batch) return formattedValue;

  final lineTotalValue = parsed * totalQuantity;
  final formattedLineTotal = lineTotalValue.toStringAsFixed(2);
  return l10n.batchCostingSummaryPricingItemScopeFormat(
    formattedLineTotal,
    formattedValue,
  );
}
