import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/history/components/history_item_actions.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

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
    final summary = data.batchQuoteSummary ?? const <String, dynamic>{};
    final items = data.batchQuoteItems;
    return Container(
      key: ValueKey<String>('$itemKeyPrefix.card'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(8, 8, 18, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                key: ValueKey<String>('$itemKeyPrefix.name'),
                data.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
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
              '${summary['itemCount'] ?? 0}',
              '${summary['totalQuantity'] ?? 0}',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _detailRow(
            context,
            l10n.batchCostingSummaryFinalTotalLabel,
            data.totalCost.toStringAsFixed(2),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            children: [
              _detailRow(
                context,
                l10n.failureRiskLabel,
                _pricingString(summary, 'failureRisk'),
              ),
              _detailRow(
                context,
                l10n.pricingMarkupPercentLabel,
                _pricingString(summary, 'markupPercent'),
              ),
              _detailRow(
                context,
                l10n.labourRateLabel,
                _pricingString(summary, 'labourRate'),
              ),
              _detailRow(
                context,
                l10n.additionalCostLabel,
                _pricingString(summary, 'additionalCostAmount'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(left: 4, right: 4),
            title: Text(
              l10n.batchHistoryItemsTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['name']?.toString() ?? ''} × ${item['quantity']?.toString() ?? '0'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
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
                            _amountString(item['baseCost']),
                          ),
                          _detailRow(
                            context,
                            l10n.batchCostingSummaryItemAdjustmentLabel,
                            _amountString(item['additionalCost']),
                          ),
                          _detailRow(
                            context,
                            l10n.batchCostingSummaryItemTotalLabel,
                            _amountString(item['finalTotal']),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }

  String _pricingString(Map<String, dynamic> summary, String key) {
    final pricing = summary['pricing'];
    if (pricing is! Map) return '—';
    final field = pricing[key];
    if (field is! Map) return '—';
    final value = field['value']?.toString() ?? '0';
    final scope = field['scope']?.toString();
    return scope == null || scope.isEmpty ? value : '$value ($scope)';
  }

  String _amountString(dynamic raw) {
    if (raw is num) return raw.toStringAsFixed(2);
    return num.tryParse(raw?.toString() ?? '')?.toStringAsFixed(2) ?? '0.00';
  }

  String _formatDurationFromMinutes(dynamic minutesValue) {
    final minutes = int.tryParse(minutesValue?.toString() ?? '') ?? 0;
    final hours = minutes ~/ 60;
    final mins = minutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
}
