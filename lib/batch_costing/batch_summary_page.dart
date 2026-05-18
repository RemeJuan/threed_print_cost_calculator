import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

class BatchSummaryPage extends ConsumerWidget {
  const BatchSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchCostingSummaryAppBarTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.batchCostingSummarySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.batchCostingSummaryPricingTitle),
            const SizedBox(height: 8),
            _pricingRow(
              context,
              label: l10n.failureRiskLabel,
              value: _pricingSummary(
                state.pricing.failureRisk.value,
                state.pricing.failureRisk.scope,
                l10n,
              ),
            ),
            _pricingRow(
              context,
              label: l10n.pricingMarkupPercentLabel,
              value: _pricingSummary(
                state.pricing.markupPercent.value,
                state.pricing.markupPercent.scope,
                l10n,
              ),
            ),
            _pricingRow(
              context,
              label: l10n.labourRateLabel,
              value: _pricingSummary(
                state.pricing.labourRate.value,
                state.pricing.labourRate.scope,
                l10n,
              ),
            ),
            _pricingRow(
              context,
              label: l10n.additionalCostLabel,
              value: _pricingSummary(
                state.pricing.additionalCostAmount.value,
                state.pricing.additionalCostAmount.scope,
                l10n,
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, l10n.batchCostingSummaryItemsTitle),
            const SizedBox(height: 8),
            for (final item in state.items)
              Card(
                child: ListTile(
                  title: Text(item.displayName),
                  subtitle: Text(
                    '${l10n.batchCostingReviewQuantityLabel}: ${item.quantity}',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  MaterialLocalizations.of(context).backButtonTooltip,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }

  Widget _pricingRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _pricingSummary(
    String value,
    BatchPricingScope scope,
    AppLocalizations l10n,
  ) {
    final scopeLabel = switch (scope) {
      BatchPricingScope.item => l10n.batchCostingMaterialAssignmentPerItemMode,
      BatchPricingScope.batch =>
        l10n.batchCostingMaterialAssignmentBatchWideMode,
    };
    return value.isEmpty ? scopeLabel : '$value · $scopeLabel';
  }
}
