import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/services/electricity_resolver.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class CalculatorResults extends ConsumerWidget {
  final CalculationResult results;
  final PricingResult pricing;

  const CalculatorResults({
    required this.results,
    this.pricing = const PricingResult.empty(),
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.watch(premiumAccessPolicyProvider);
    final isPremium = policy.isPremium;
    final shouldShowProPromotion = policy.shouldShowPromotions;
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();
    final additionalCostAmount = ref.watch(
      calculatorProvider.select(
        (state) => state.additionalCostAmount.value ?? 0,
      ),
    );
    const width = kIsWeb ? 250.0 : null;

    return AppSurfaceCard(
      backgroundColor: CALCULATOR_SURFACE,
      padding: const EdgeInsets.all(kAppSpace8),
      margin: const EdgeInsets.symmetric(vertical: kAppSpace8),
      width: width,
      child: Column(
        children: [
          _itemRow(
            context,
            l10n.resultElectricityPrefix,
            results.electricity,
            currencySettings: currencySettings,
            key: const ValueKey<String>('calculator.result.electricityCost'),
          ),
          _itemRow(
            context,
            l10n.resultFilamentPrefix,
            results.filament,
            currencySettings: currencySettings,
            key: const ValueKey<String>('calculator.result.filamentCost'),
          ),
          if (policy.riskPricing().allowed)
            _itemRow(
              context,
              l10n.riskTotalPrefix,
              results.risk,
              currencySettings: currencySettings,
              key: const ValueKey<String>('calculator.result.riskCost'),
            ),
          if (policy.labourPricing().allowed)
            _itemRow(
              context,
              l10n.labourCostPrefix,
              results.total -
                  results.electricity -
                  results.filament -
                  results.risk -
                  additionalCostAmount,
              currencySettings: currencySettings,
              key: const ValueKey<String>('calculator.result.labourCost'),
            ),
          if (additionalCostAmount > 0)
            _itemRow(
              context,
              l10n.additionalCostLabel,
              additionalCostAmount,
              currencySettings: currencySettings,
              key: const ValueKey<String>('calculator.result.additionalCost'),
            ),
          if (!policy.riskPricing().allowed && shouldShowProPromotion) ...[
            _lockedPromoRow(
              context,
              l10n.wearAndTearLabel,
              l10n.lockedValuePlaceholder,
              key: const ValueKey<String>(
                'calculator.result.locked.wearAndTear',
              ),
            ),
            _lockedPromoRow(
              context,
              l10n.riskTotalPrefix,
              l10n.lockedValuePlaceholder,
              key: const ValueKey<String>('calculator.result.locked.riskCost'),
            ),
          ],
          if (!policy.labourPricing().allowed && shouldShowProPromotion)
            _lockedPromoRow(
              context,
              l10n.labourCostPrefix,
              l10n.lockedValuePlaceholder,
              key: const ValueKey<String>(
                'calculator.result.locked.labourCost',
              ),
            ),
          const Divider(),
          _summaryRow(
            context,
            l10n.costTotalLabel,
            results.total,
            currencySettings: currencySettings,
            key: const ValueKey<String>('calculator.result.totalCost'),
            emphasize: !pricing.isEnabled,
          ),
          if (isPremium && pricing.isEnabled) ...[
            const Divider(),
            _itemRow(
              context,
              '${l10n.markupLabel} (${formatPercent(pricing.markupPercent)}%)',
              pricing.markupAmount,
              currencySettings: currencySettings,
              key: const ValueKey<String>('calculator.result.markupAmount'),
            ),
            if (pricing.setupFee > 0)
              _itemRow(
                context,
                l10n.setupFeeLabel,
                pricing.setupFee,
                currencySettings: currencySettings,
                key: const ValueKey<String>('calculator.result.setupFee'),
              ),
            if (pricing.roundingAdjustment != 0)
              _itemRow(
                context,
                l10n.roundingAdjustmentLabel,
                pricing.roundingAdjustment,
                currencySettings: currencySettings,
                key: const ValueKey<String>(
                  'calculator.result.roundingAdjustment',
                ),
              ),
            _summaryRow(
              context,
              l10n.finalPriceLabel,
              pricing.finalPrice,
              currencySettings: currencySettings,
              key: const ValueKey<String>('calculator.result.finalPrice'),
              emphasize: true,
            ),
          ],
        ],
      ),
    );
  }

  Padding _itemRow(
    BuildContext context,
    String prefix,
    num value, {
    Key? key,
    required GeneralSettingsModel currencySettings,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              prefix,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: TEXT_SECONDARY) ??
                  const TextStyle(color: TEXT_SECONDARY),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrencyValue(
              value,
              currencySymbol: currencySettings.currencySymbol,
              currencyPosition: currencySettings.currencyPosition,
              currencySpacing: currencySettings.currencySpacing,
            ),
            key: key,
          ),
        ],
      ),
    );
  }

  Padding _summaryRow(
    BuildContext context,
    String label,
    num value, {
    Key? key,
    required bool emphasize,
    required GeneralSettingsModel currencySettings,
  }) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: TEXT_PRIMARY,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrencyValue(
              value,
              currencySymbol: currencySettings.currencySymbol,
              currencyPosition: currencySettings.currencyPosition,
              currencySpacing: currencySettings.currencySpacing,
            ),
            key: key,
            style: style,
          ),
        ],
      ),
    );
  }

  Padding _lockedPromoRow(
    BuildContext context,
    String label,
    String placeholder, {
    Key? key,
  }) {
    const mutedColor = TEXT_TERTIARY;
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: mutedColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style:
                        Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: mutedColor) ??
                        const TextStyle(color: mutedColor),
                  ),
                ),
              ],
            ),
          ),
          Text(
            placeholder,
            style:
                Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: mutedColor) ??
                const TextStyle(color: mutedColor),
          ),
        ],
      ),
    );
  }
}
