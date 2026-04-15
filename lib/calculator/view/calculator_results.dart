import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';

class CalculatorResults extends ConsumerWidget {
  final CalculationResult results;

  const CalculatorResults({required this.results, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);
    final shouldShowProPromotion = ref.watch(shouldShowProPromotionProvider);
    const width = kIsWeb ? 250.0 : null;

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(8, 8, 18, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      width: width,
      child: Column(
        children: [
          _itemRow(
            context,
            l10n.resultElectricityPrefix,
            results.electricity,
            key: const ValueKey<String>('calculator.result.electricityCost'),
          ),
          _itemRow(
            context,
            l10n.resultFilamentPrefix,
            results.filament,
            key: const ValueKey<String>('calculator.result.filamentCost'),
          ),
          if (isPremium) ...[
            _itemRow(
              context,
              l10n.riskTotalPrefix,
              results.risk,
              key: const ValueKey<String>('calculator.result.riskCost'),
            ),
            _itemRow(
              context,
              l10n.labourCostPrefix,
              results.labour,
              key: const ValueKey<String>('calculator.result.labourCost'),
            ),
          ] else if (shouldShowProPromotion) ...[
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
            _lockedPromoRow(
              context,
              l10n.labourCostPrefix,
              l10n.lockedValuePlaceholder,
              key: const ValueKey<String>(
                'calculator.result.locked.labourCost',
              ),
            ),
          ],
          Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.resultTotalPrefix,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  key: const ValueKey<String>('calculator.result.totalCost'),
                  results.total.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _itemRow(BuildContext context, String prefix, num value, {Key? key}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prefix,
            style:
                Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70) ??
                const TextStyle(color: Colors.white70),
          ),
          Text(value.toString(), key: key),
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
    const mutedColor = Colors.white38;

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
