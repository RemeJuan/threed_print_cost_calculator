import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';

import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

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
      if (!ref.read(batchCostingEnabledProvider)) return;
      final s = ref.read(batchCostingProvider);
      final copyCount = s.items.fold<int>(0, (sum, item) => sum + item.quantity);
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
          hasSplitPrinters: _hasSplitPrinters(s),
          hasSplitMaterials: _hasSplitMaterials(s),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

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
      appBar: AppBar(
        title: Text(l10n.batchCostingSummaryAppBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
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
              Card(
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                  onPressed: () => _saveQuote(context, state, summary),
                  child: Text(l10n.batchCostingSummarySaveButton),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Text(l10n.batchCostingSummaryReturnToCalculatorButton),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _showStartNewBatchDialog(context),
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
    AppLocalizations l10n,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.batchCostingSummaryAppBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
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
                    onPressed: () => _showStartNewBatchDialog(context),
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

  Future<void> _saveQuote(
    BuildContext context,
    BatchCostingState state,
    BatchSummaryResult summary,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final quoteName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController(
          text: l10n.batchCostingSummaryDefaultQuoteName,
        );
        return AlertDialog(
          title: Text(l10n.batchCostingSummaryQuoteNameDialogTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.batchCostingSummaryDefaultQuoteName,
              labelText: l10n.batchCostingSummaryQuoteNameHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                Navigator.of(dialogContext).pop(
                  name.isEmpty
                      ? l10n.batchCostingSummaryDefaultQuoteName
                      : name,
                );
              },
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );

    if (quoteName == null || !context.mounted) return;

    final model = HistoryModel.batchQuote(
      name: quoteName,
      date: DateTime.now(),
      state: state,
      summary: summary,
    );

    final copyCount = state.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final hasGCode = state.items.any(
      (item) => item.sourceType == BatchCostingItemSourceType.gcode,
    );
    final hasManual = state.items.any(
      (item) => item.sourceType == BatchCostingItemSourceType.manual,
    );
    final hasSplitP = _hasSplitPrinters(state);
    final hasSplitM = _hasSplitMaterials(state);

    try {
      await ref.read(historyRepositoryProvider).saveHistory(model);
    } catch (e, st) {
      debugPrint('batch_summary_page._saveQuote error: $e\n$st');
      AppAnalytics.safeLog(
        () => AppAnalytics.batchQuoteSaved(
          outcome: 'failure',
          itemCount: state.items.length,
          copyCount: copyCount,
          hasGCodeItems: hasGCode,
          hasManualItems: hasManual,
          hasSplitPrinters: hasSplitP,
          hasSplitMaterials: hasSplitM,
        ),
      );
      if (!context.mounted) return;
      BotToast.showText(text: l10n.batchCostingSummarySaveErrorMessage);
      return;
    }

    AppAnalytics.safeLog(
      () => AppAnalytics.batchQuoteSaved(
        outcome: 'success',
        itemCount: state.items.length,
        copyCount: copyCount,
        hasGCodeItems: hasGCode,
        hasManualItems: hasManual,
        hasSplitPrinters: hasSplitP,
        hasSplitMaterials: hasSplitM,
      ),
    );

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.batchCostingSummarySaveSuccessTitle),
        content: Text(l10n.batchCostingSummarySaveSuccessBody),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  ref
                      .read(pendingTabNavigationProvider.notifier)
                      .navigate(AppPageTab.history);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(l10n.batchCostingSummaryViewHistoryButton),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(l10n.batchCostingSummaryReturnToCalculatorButton),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _showStartNewBatchDialog(context);
                },
                child: Text(l10n.batchCostingSummaryStartNewBatchButton),
              ),
            ],
          ),
        ],
      ),
    );
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

  bool _hasSplitPrinters(BatchCostingState s) {
    if (s.printerAssignmentMode != BatchPrinterAssignmentMode.perItem) {
      return false;
    }
    return s.items.any((item) {
      final allocs = s.itemPrinterAllocations[item.id];
      if (allocs == null || allocs.length <= 1) return false;
      return allocs.map((a) => a.targetId).toSet().length > 1;
    });
  }

  bool _hasSplitMaterials(BatchCostingState s) {
    if (s.materialAssignmentMode != BatchMaterialAssignmentMode.perItem) {
      return false;
    }
    return s.items.any((item) {
      final allocs = s.itemMaterialAllocations[item.id];
      if (allocs == null || allocs.length <= 1) return false;
      return allocs.map((a) => a.targetId).toSet().length > 1;
    });
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
