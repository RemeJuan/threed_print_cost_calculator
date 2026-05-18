import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
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
    if (state.items.isEmpty) {
      return _emptyState(context, l10n);
    }

    final summary = BatchSummaryCalculator.calculate(state);

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
            _sectionTitle(context, l10n.batchCostingSummaryOverviewTitle),
            const SizedBox(height: 8),
            _summaryRow(context, l10n.batchCostingSummaryItemCountLabel, summary.itemCount.toString()),
            _summaryRow(context, l10n.batchCostingSummaryTotalQuantityLabel, summary.totalQuantity.toString()),
            _summaryRow(context, l10n.batchCostingSummaryTotalWeightLabel, '${summary.totalWeightG.toStringAsFixed(2)} ${l10n.gramsSuffix}'),
            _summaryRow(context, l10n.batchCostingSummaryTotalDurationLabel, _formatDuration(summary.totalPrintDuration)),
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.batchCostingSummaryPricingTitle),
            const SizedBox(height: 8),
            _pricingRow(
              context,
              label: l10n.failureRiskLabel,
              value: _pricingSummary(summary.failureRisk.value, summary.failureRisk.scope, l10n),
            ),
            _pricingRow(
              context,
              label: l10n.pricingMarkupPercentLabel,
              value: _pricingSummary(summary.markupPercent.value, summary.markupPercent.scope, l10n),
            ),
            _pricingRow(
              context,
              label: l10n.labourRateLabel,
              value: _pricingSummary(summary.labourRate.value, summary.labourRate.scope, l10n),
            ),
            _pricingRow(
              context,
              label: l10n.additionalCostLabel,
              value: _pricingSummary(state.pricing.additionalCostAmount.value, state.pricing.additionalCostAmount.scope, l10n),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, l10n.batchCostingSummaryItemsTitle),
            const SizedBox(height: 8),
            for (final item in summary.items)
              Card(
                child: ExpansionTile(
                  title: Text(item.item.displayName),
                  subtitle: Text('${l10n.batchCostingReviewQuantityLabel}: ${item.totalQuantity}'),
                  children: [
                    _summaryRow(context, l10n.batchCostingSummaryItemWeightLabel, '${item.totalWeightG.toStringAsFixed(2)} ${l10n.gramsSuffix}'),
                    _summaryRow(context, l10n.batchCostingSummaryItemDurationLabel, _formatDuration(item.totalPrintDuration)),
                    _summaryRow(context, l10n.batchCostingSummaryItemBaseCostLabel, item.baseCost.toStringAsFixed(2)),
                    _summaryRow(context, l10n.batchCostingSummaryItemAdjustmentLabel, item.additionalCost.toStringAsFixed(2)),
                    _summaryRow(context, l10n.batchCostingSummaryItemTotalLabel, item.pricing.finalPrice.toStringAsFixed(2)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _summaryRow(context, l10n.batchCostingSummaryFinalTotalLabel, summary.finalTotal.toStringAsFixed(2)),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.batchCostingSummaryBackButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchCostingSummaryAppBarTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              Text(l10n.batchCostingSummaryEmptyTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(l10n.batchCostingSummaryEmptyBody, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.batchCostingSummaryBackButton),
              ),
            ],
          ),
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

  Widget _summaryRow(BuildContext context, String label, String value) {
    return _pricingRow(context, label: label, value: value);
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
