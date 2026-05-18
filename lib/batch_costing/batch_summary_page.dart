import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class BatchSummaryPage extends ConsumerWidget {
  const BatchSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);
    if (state.items.isEmpty) {
      return _emptyState(context, ref, l10n);
    }

    final summary = BatchSummaryCalculator.calculate(state);

    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();

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
            _summaryRow(
              context,
              l10n.batchCostingSummaryItemCountLabel,
              summary.itemCount.toString(),
            ),
            _summaryRow(
              context,
              l10n.batchCostingSummaryTotalQuantityLabel,
              summary.totalQuantity.toString(),
            ),
            _summaryRow(
              context,
              l10n.batchCostingSummaryTotalWeightLabel,
              '${summary.totalWeightG.toStringAsFixed(2)} ${l10n.gramsSuffix}',
            ),
            _summaryRow(
              context,
              l10n.batchCostingSummaryTotalDurationLabel,
              _formatDuration(summary.totalPrintDuration),
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.batchCostingSummaryPricingTitle),
            const SizedBox(height: 8),
            _pricingRow(
              context,
              label: l10n.failureRiskLabel,
              value: _pricingSummary(
                summary.failureRisk.value,
                summary.failureRisk.scope,
                summary.totalQuantity,
                l10n,
                currencySettings,
                isPercent: true,
              ),
            ),
            _pricingRow(
              context,
              label: l10n.pricingMarkupPercentLabel,
              value: _pricingSummary(
                summary.markupPercent.value,
                summary.markupPercent.scope,
                summary.totalQuantity,
                l10n,
                currencySettings,
                isPercent: true,
              ),
            ),
            _pricingRow(
              context,
              label: l10n.labourRateLabel,
              value: _pricingSummary(
                summary.labourRate.value,
                summary.labourRate.scope,
                summary.totalQuantity,
                l10n,
                currencySettings,
              ),
            ),
            _pricingRow(
              context,
              label: l10n.additionalCostLabel,
              value: _pricingSummary(
                state.pricing.additionalCostAmount.value,
                state.pricing.additionalCostAmount.scope,
                summary.totalQuantity,
                l10n,
                currencySettings,
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, l10n.batchCostingSummaryItemsTitle),
            const SizedBox(height: 8),
            for (final item in summary.items)
              Card(
                child: ExpansionTile(
                  title: Text(item.item.displayName),
                  subtitle: Text(
                    '${l10n.batchCostingReviewQuantityLabel}: ${item.totalQuantity}',
                  ),
                  children: [
                    _summaryRow(
                      context,
                      l10n.batchCostingSummaryItemWeightLabel,
                      '${item.totalWeightG.toStringAsFixed(2)} ${l10n.gramsSuffix}',
                    ),
                    _summaryRow(
                      context,
                      l10n.batchCostingSummaryItemDurationLabel,
                      _formatDuration(item.totalPrintDuration),
                    ),
                    _summaryRow(
                      context,
                      l10n.batchCostingSummaryItemBaseCostLabel,
                      formatCurrencyValue(
                        item.baseCost,
                        currencySymbol: currencySettings.currencySymbol,
                        currencyPosition: currencySettings.currencyPosition,
                        currencySpacing: currencySettings.currencySpacing,
                      ),
                    ),
                    _summaryRow(
                      context,
                      l10n.batchCostingSummaryItemAdjustmentLabel,
                      formatCurrencyValue(
                        item.additionalCost,
                        currencySymbol: currencySettings.currencySymbol,
                        currencyPosition: currencySettings.currencyPosition,
                        currencySpacing: currencySettings.currencySpacing,
                      ),
                    ),
                    _summaryRow(
                      context,
                      l10n.batchCostingSummaryItemTotalLabel,
                      _lineTotalWithQuantity(item, currencySettings),
                    ),
                  ],
                ),
              ),
            Card(
              color: DEEP_BLUE,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      l10n.batchCostingSummaryFinalTotalLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      formatCurrencyValue(
                        summary.finalTotal,
                        currencySymbol: currencySettings.currencySymbol,
                        currencyPosition: currencySettings.currencyPosition,
                        currencySpacing: currencySettings.currencySpacing,
                      ),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.batchCostingSummaryBackButton),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Text(l10n.batchCostingSummaryReturnToCalculatorButton),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _showStartNewBatchDialog(context, ref),
                  child: Text(l10n.batchCostingSummaryStartNewBatchButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchCostingSummaryAppBarTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.batchCostingSummaryEmptyTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.batchCostingSummaryEmptyBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.batchCostingSummaryBackButton),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    child: Text(
                      l10n.batchCostingSummaryReturnToCalculatorButton,
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _showStartNewBatchDialog(context, ref),
                    child: Text(l10n.batchCostingSummaryStartNewBatchButton),
                  ),
                ],
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
    int totalQuantity,
    AppLocalizations l10n,
    GeneralSettingsModel currencySettings, {
    bool isPercent = false,
  }) {
    if (value.isEmpty) return '';
    final formattedValue = isPercent
        ? value
        : formatCurrencyValue(
            double.tryParse(value.replaceAll(',', '.')) ?? 0,
            currencySymbol: currencySettings.currencySymbol,
            currencyPosition: currencySettings.currencyPosition,
            currencySpacing: currencySettings.currencySpacing,
          );
    if (scope == BatchPricingScope.batch) return formattedValue;

    final perUnit = double.tryParse(value.replaceAll(',', '.')) ?? 0;
    final lineTotalValue = perUnit * totalQuantity;
    final formattedLineTotal = isPercent
        ? lineTotalValue.toStringAsFixed(1)
        : formatCurrencyValue(
            lineTotalValue,
            currencySymbol: currencySettings.currencySymbol,
            currencyPosition: currencySettings.currencyPosition,
            currencySpacing: currencySettings.currencySpacing,
          );
    return l10n.batchCostingSummaryPricingItemScopeFormat(
      formattedValue,
      formattedLineTotal,
    );
  }

  Future<void> _showStartNewBatchDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.batchCostingNewBatchDialogTitle),
        content: Text(l10n.batchCostingNewBatchDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.batchCostingSummaryStartNewBatchButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    ref.read(batchCostingProvider.notifier).reset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _lineTotalWithQuantity(
    BatchSummaryItemBreakdown item,
    GeneralSettingsModel currencySettings,
  ) {
    final finalTotal = formatCurrencyValue(
      item.pricing.finalPrice,
      currencySymbol: currencySettings.currencySymbol,
      currencyPosition: currencySettings.currencyPosition,
      currencySpacing: currencySettings.currencySpacing,
    );
    if (item.totalQuantity <= 1) return finalTotal;

    final perCopy = formatCurrencyValue(
      item.pricing.finalPrice / item.totalQuantity,
      currencySymbol: currencySettings.currencySymbol,
      currencyPosition: currencySettings.currencyPosition,
      currencySpacing: currencySettings.currencySpacing,
    );
    return '$finalTotal ($perCopy × ${item.totalQuantity})';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
