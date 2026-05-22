import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_quote_save_service.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_new_batch_dialog.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_expansion_card.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';
import 'package:threed_print_cost_calculator/shared/widgets/home_button.dart';

class BatchSummaryPage extends ConsumerStatefulWidget {
  const BatchSummaryPage({super.key});

  @override
  ConsumerState<BatchSummaryPage> createState() => _BatchSummaryPageState();
}

class _BatchSummaryPageState extends ConsumerState<BatchSummaryPage> {
  var _analyticsFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _analyticsFired) return;
      _analyticsFired = true;

      final s = ref.read(batchCostingProvider);
      final copyCount = s.items.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );
      AppAnalytics.safeLog(
        () => AppAnalytics.batchSummaryViewed(
          itemCount: s.items.length,
          copyCount: copyCount,
          hasGCodeItems: s.items.any(
            (item) => item.sourceType == BatchCostingItemSourceType.gcode,
          ),
          hasManualItems: s.items.any(
            (item) => item.sourceType == BatchCostingItemSourceType.manual,
          ),
          hasSplitPrinters: s.hasSplitPrinters,
          hasSplitMaterials: s.hasSplitMaterials,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);
    if (state.items.isEmpty) {
      return _emptyState(context, l10n);
    }

    final summary = BatchSummaryCalculator.calculate(state);

    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();

    return Scaffold(
      appBar: AppScreenHeader(
        title: l10n.batchCostingSummaryAppBarTitle,
        actions: [homeButton(context)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kAppSpace16),
          children: [
            Text(
              l10n.batchCostingSummarySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: kAppSpace16),
            _sectionTitle(context, l10n.batchCostingSummaryOverviewTitle),
            const SizedBox(height: kAppSpace8),
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
              formatDuration(summary.totalPrintDuration),
            ),
            const SizedBox(height: kAppSpace16),
            _sectionTitle(context, l10n.batchCostingSummaryPricingTitle),
            const SizedBox(height: kAppSpace8),
            if (_showPricing(summary.failureRisk.value))
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
                  monetaryImpact: summary.failureRiskMonetary,
                ),
              ),
            if (_showPricing(summary.markupPercent.value))
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
                  monetaryImpact: summary.markupPercentMonetary,
                ),
              ),
            if (_showPricing(summary.labourRate.value))
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
            if (_showPricing(state.pricing.additionalCostAmount.value))
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
              Padding(
                padding: const EdgeInsets.only(bottom: kAppSpace12),
                child: AppExpansionCard(
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
                      formatDuration(item.totalPrintDuration),
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
            AppSurfaceCard(
              backgroundColor: RESULT_SURFACE,
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: AppTertiaryButton(
                onPressed: () => Navigator.of(context).pop(),
                label: l10n.batchCostingSummaryBackButton,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPrimaryButton(
                  onPressed: () => saveBatchQuote(context, ref, state, summary),
                  label: l10n.batchCostingSummarySaveButton,
                ),
                const SizedBox(height: 12),
                AppPrimaryButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  label: l10n.batchCostingSummaryReturnToCalculatorButton,
                ),
                const SizedBox(height: 12),
                AppSecondaryButton(
                  onPressed: () => _showStartNewBatchDialog(context),
                  label: l10n.batchCostingSummaryStartNewBatchButton,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppScreenHeader(
        title: l10n.batchCostingSummaryAppBarTitle,
        actions: [homeButton(context)],
      ),
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
                  AppTertiaryButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: l10n.batchCostingSummaryBackButton,
                  ),
                  AppSecondaryButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    label: l10n.batchCostingSummaryReturnToCalculatorButton,
                  ),
                  AppPrimaryButton(
                    onPressed: () => _showStartNewBatchDialog(context),
                    label: l10n.batchCostingSummaryStartNewBatchButton,
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
    num monetaryImpact = 0,
  }) {
    if (value.isEmpty) return '';
    final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0;

    if (isPercent) {
      final formattedValue = '$value%';
      final formattedImpact = formatCurrencyValue(
        monetaryImpact,
        currencySymbol: currencySettings.currencySymbol,
        currencyPosition: currencySettings.currencyPosition,
        currencySpacing: currencySettings.currencySpacing,
      );
      if (scope == BatchPricingScope.batch) {
        return '$formattedValue → $formattedImpact';
      }
      return l10n.batchCostingSummaryPricingItemScopeFormat(
        formattedImpact,
        formattedValue,
      );
    }

    final formattedValue = formatCurrencyValue(
      parsed,
      currencySymbol: currencySettings.currencySymbol,
      currencyPosition: currencySettings.currencyPosition,
      currencySpacing: currencySettings.currencySpacing,
    );
    if (scope == BatchPricingScope.batch) return formattedValue;

    final lineTotalValue = parsed * totalQuantity;
    final formattedLineTotal = formatCurrencyValue(
      lineTotalValue,
      currencySymbol: currencySettings.currencySymbol,
      currencyPosition: currencySettings.currencyPosition,
      currencySpacing: currencySettings.currencySpacing,
    );
    return l10n.batchCostingSummaryPricingItemScopeFormat(
      formattedLineTotal,
      formattedValue,
    );
  }

  Future<void> _showStartNewBatchDialog(BuildContext context) async {
    final confirmed = await showStartNewBatchDialog(context);
    if (!confirmed) return;
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

  bool _showPricing(String value) => value.isNotEmpty && value != '0';
}
