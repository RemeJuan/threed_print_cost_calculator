import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_actions.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';

class BatchHistoryItem extends HookConsumerWidget {
  const BatchHistoryItem({
    required this.dbKey,
    required this.data,
    required this.itemKeyPrefix,
    this.onOverflowMenuOpened,
    this.deleteHistoryEntry,
    this.exportCsv = exportCSVFile,
    super.key,
  });

  final String dbKey;
  final HistoryModel data;
  final String itemKeyPrefix;
  final VoidCallback? onOverflowMenuOpened;
  final Future<void> Function(WidgetRef ref, String dbKey)? deleteHistoryEntry;
  final HistoryItemExportCsv exportCsv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final summary = data.batchQuoteSummary;
    final items = data.batchQuoteItems;
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currency = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();
    return Container(
      key: ValueKey<String>('$itemKeyPrefix.card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                key: ValueKey<String>('$itemKeyPrefix.name'),
                data.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: TEXT_PRIMARY,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              HistoryItemActions(
                dbKey: dbKey,
                data: data,
                itemKeyPrefix: itemKeyPrefix,
                onOverflowMenuOpened: onOverflowMenuOpened,
                deleteHistoryEntry: deleteHistoryEntry,
                exportCsv: exportCsv,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.batchHistorySummaryLine(
              (summary?['itemCount'] as num?)?.toInt() ??
                  items.map((e) => e['name']?.toString()).toSet().length,
              (summary?['totalQuantity'] as num?)?.toInt() ??
                  items.fold<int>(
                    0,
                    (sum, e) => sum + ((e['quantity'] as num?)?.toInt() ?? 0),
                  ),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _detailRow(
            context,
            l10n.batchCostingSummaryFinalTotalLabel,
            _amountString(data.totalCost, currency),
          ),
          _detailRow(
            context,
            l10n.batchCostingSummaryTotalWeightLabel,
            '${data.weight.toStringAsFixed(2)} ${l10n.gramsSuffix}',
          ),
          _detailRow(
            context,
            l10n.batchCostingSummaryTotalDurationLabel,
            data.timeHours,
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(left: 4, right: 4),
            title: Text(
              l10n.batchCostingSummaryPricingTitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: TEXT_SECONDARY),
            ),
            children: [
              for (final entry in _pricingEntries(
                l10n,
                summary ?? const <String, dynamic>{},
                currency,
              ))
                if (entry.value != null)
                  _detailRow(context, entry.label, entry.value!),
            ],
          ),
          const SizedBox(height: kAppSpace4),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.symmetric(horizontal: kAppSpace4),
            title: Text(
              l10n.batchHistoryItemsTitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: TEXT_SECONDARY),
            ),
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: kAppSpace8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: SURFACE_OVERLAY_SUBTLE,
                      borderRadius: BorderRadius.circular(kAppSurfaceRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(kAppSpace8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['name']?.toString() ?? ''} × ${item['quantity']?.toString() ?? '0'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: TEXT_PRIMARY),
                          ),
                          const SizedBox(height: kAppSpace4),
                          _detailRow(
                            context,
                            l10n.batchCostingSummaryItemWeightLabel,
                            '${item['totalWeightG']?.toString() ?? '0'} ${l10n.gramsSuffix}',
                          ),
                          _detailRow(
                            context,
                            l10n.batchCostingSummaryItemDurationLabel,
                            _formatDurationFromMinutes(
                              item['totalPrintDurationMinutes'],
                            ),
                          ),
                          _detailRow(
                            context,
                            l10n.batchCostingSummaryItemBaseCostLabel,
                            _amountString(item['baseCost'], currency),
                          ),
                          if ((item['additionalCost'] as num?) != 0)
                            _detailRow(
                              context,
                              l10n.batchCostingSummaryItemAdjustmentLabel,
                              _amountString(item['additionalCost'], currency),
                            ),
                          _detailRow(
                            context,
                            l10n.batchCostingSummaryItemTotalLabel,
                            _amountString(item['finalTotal'], currency),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kAppSpace4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: TEXT_SECONDARY),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: TEXT_PRIMARY),
          ),
        ],
      ),
    );
  }

  List<({String label, String? value})> _pricingEntries(
    AppLocalizations l10n,
    Map<String, dynamic> summary,
    GeneralSettingsModel currency,
  ) {
    final pricing = summary['pricing'];
    if (pricing is! Map) return [];
    return [
      (
        label: l10n.failureRiskLabel,
        value: _pricingValue(
          pricing,
          'failureRisk',
          l10n,
          currency,
          isPercent: true,
        ),
      ),
      (
        label: l10n.pricingMarkupPercentLabel,
        value: _pricingValue(
          pricing,
          'markupPercent',
          l10n,
          currency,
          isPercent: true,
        ),
      ),
      (
        label: l10n.labourRateLabel,
        value: _pricingValue(pricing, 'labourRate', l10n, currency),
      ),
      (
        label: l10n.additionalCostLabel,
        value: _pricingValue(pricing, 'additionalCostAmount', l10n, currency),
      ),
    ];
  }

  String? _pricingValue(
    Map pricing,
    String key,
    AppLocalizations l10n,
    GeneralSettingsModel currency, {
    bool isPercent = false,
  }) {
    final field = pricing[key];
    if (field is! Map) return null;
    final raw = (field['value']?.toString() ?? '').trim();
    if (raw.isEmpty || raw == '0') return null;
    final monetaryImpact = field['monetaryImpact'];
    if (isPercent) {
      if (monetaryImpact is num && monetaryImpact > 0) {
        final impact = formatCurrencyValue(
          monetaryImpact,
          currencySymbol: currency.currencySymbol,
          currencyPosition: currency.currencyPosition,
          currencySpacing: currency.currencySpacing,
        );
        return '$raw% → $impact';
      }
      return '$raw%';
    }
    return raw;
  }

  String _amountString(dynamic raw, GeneralSettingsModel currency) {
    final num value = raw is num
        ? raw
        : (num.tryParse(raw?.toString() ?? '') ?? 0);
    if (value == 0 && raw is! num) return '0.00';
    return formatCurrencyValue(
      value,
      currencySymbol: currency.currencySymbol,
      currencyPosition: currency.currencyPosition,
      currencySpacing: currency.currencySpacing,
    );
  }

  String _formatDurationFromMinutes(dynamic minutesValue) {
    final minutes = int.tryParse(minutesValue?.toString() ?? '') ?? 0;
    final hours = minutes ~/ 60;
    final mins = minutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
}
