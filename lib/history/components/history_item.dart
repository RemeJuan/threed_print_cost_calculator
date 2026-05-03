import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_providers.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_actions.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

class HistoryItem extends HookConsumerWidget {
  final String dbKey;
  final HistoryModel data;
  final Future<void> Function()? onHistoryLoaded;
  final VoidCallback? onOverflowMenuOpened;
  final Future<void> Function(WidgetRef ref, String dbKey)? deleteHistoryEntry;
  final HistoryItemExportCsv exportCsv;

  const HistoryItem({
    required this.dbKey,
    required this.data,
    this.onHistoryLoaded,
    this.onOverflowMenuOpened,
    this.deleteHistoryEntry,
    this.exportCsv = exportCSVFile,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();
    final materialsById = ref.watch(materialsByIdProvider);
    final itemKeyPrefix = 'history.item.${data.name}';
    final actionsController = HistoryItemActionsController(
      dbKey: dbKey,
      data: data,
      onHistoryLoaded: onHistoryLoaded,
      deleteHistoryEntry: deleteHistoryEntry,
      exportCsv: exportCsv,
    );

    return Slidable(
      key: ValueKey(dbKey),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) async => actionsController.deleteEntry(context, ref),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: l10n.deleteButton,
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            key: ValueKey<String>('$itemKeyPrefix.card'),
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                      onHistoryLoaded: onHistoryLoaded,
                      onOverflowMenuOpened: onOverflowMenuOpened,
                      deleteHistoryEntry: deleteHistoryEntry,
                      exportCsv: exportCsv,
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(data.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _row(
                  context,
                  l10n.electricityCostLabel,
                  data.electricityCost,
                  currencySettings: currencySettings,
                  key: ValueKey<String>('$itemKeyPrefix.electricityCost'),
                ),
                _row(
                  context,
                  l10n.filamentCostLabel,
                  data.filamentCost,
                  currencySettings: currencySettings,
                  key: ValueKey<String>('$itemKeyPrefix.filamentCost'),
                ),
                _row(
                  context,
                  l10n.labourCostLabel,
                  data.labourCost,
                  currencySettings: currencySettings,
                  key: ValueKey<String>('$itemKeyPrefix.labourCost'),
                ),
                if (data.additionalCostAmount > 0)
                  _row(
                    context,
                    l10n.additionalCostLabel,
                    data.additionalCostAmount,
                    currencySettings: currencySettings,
                    key: ValueKey<String>('$itemKeyPrefix.additionalCost'),
                  ),
                _row(
                  context,
                  l10n.riskCostLabel,
                  data.riskCost,
                  currencySettings: currencySettings,
                  key: ValueKey<String>('$itemKeyPrefix.riskCost'),
                ),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      data.finalPrice == null
                          ? l10n.totalCostLabel
                          : l10n.costTotalLabel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: data.finalPrice == null
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      key: ValueKey<String>('$itemKeyPrefix.totalCost'),
                      formatCurrencyValue(data.totalCost, currencySymbol: currencySettings.currencySymbol, currencyPosition: currencySettings.currencyPosition, currencySpacing: currencySettings.currencySpacing),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: data.finalPrice == null
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (data.finalPrice != null) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 4),
                  if (data.pricingMarkupAmount != null)
                    _row(
                      context,
                      '${l10n.markupLabel} (${formatPercent(data.pricingMarkupPercent)}%)',
                      data.pricingMarkupAmount!,
                      currencySettings: currencySettings,
                      key: ValueKey<String>('$itemKeyPrefix.markupAmount'),
                    ),
                  if ((data.pricingSetupFee ?? 0) > 0)
                    _row(
                      context,
                      l10n.setupFeeLabel,
                      data.pricingSetupFee!,
                      currencySettings: currencySettings,
                      key: ValueKey<String>('$itemKeyPrefix.setupFee'),
                    ),
                  if ((data.pricingRoundingAdjustment ?? 0) != 0)
                    _row(
                      context,
                      l10n.roundingAdjustmentLabel,
                      data.pricingRoundingAdjustment ?? 0,
                      currencySettings: currencySettings,
                      key: ValueKey<String>(
                        '$itemKeyPrefix.roundingAdjustment',
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        l10n.finalPriceLabel,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        key: ValueKey<String>('$itemKeyPrefix.finalPrice'),
                        formatCurrencyValue(data.finalPrice!, currencySymbol: currencySettings.currencySymbol, currencyPosition: currencySettings.currencyPosition, currencySpacing: currencySettings.currencySpacing),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                // Additional summary line: weight (kg) • time (e.g. 6h 20m) • printer • material
                Builder(
                  builder: (context) {
                    final weightKg = (data.weight / 1000);
                    // parse timeHours which should be in "hh:mm" format
                    String timeLabel;
                    try {
                      final parts = data.timeHours.split(':');
                      final h = int.tryParse(parts[0]) ?? 0;
                      final m =
                          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
                      timeLabel = l10n.historyTimeCompactLabel(
                        h.toString(),
                        m.toString(),
                      );
                    } catch (_) {
                      timeLabel = data.timeHours;
                    }

                    final summary = l10n.historySummaryLabel(
                      l10n.historyWeightCompactLabel(
                        weightKg.toStringAsFixed(2),
                      ),
                      timeLabel,
                      data.printer,
                      data.material,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key: ValueKey<String>('$itemKeyPrefix.summary'),
                          summary,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (data.materialUsages.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          // Small accordion for material breakdown. Constrain height so
                          // long lists remain scrollable and don't expand the history item.
                          Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              // Minimal padding so the tile aligns with surrounding content
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              collapsedBackgroundColor: Colors.transparent,
                              // Make chevron visible on dark background
                              iconColor: Colors.white70,
                              collapsedIconColor: Colors.white54,
                              title: Text(
                                l10n.materialBreakdownLabel,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              children: [
                                SingleChildScrollView(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      data.materialUsages.length,
                                      (idx) {
                                        final usage = data.materialUsages[idx];
                                        final weight =
                                            int.tryParse(
                                              usage['weightGrams'].toString(),
                                            ) ??
                                            0;

                                        String materialLabel;
                                        final materialId = usage['materialId']
                                            ?.toString();
                                        if (materialId != null &&
                                            materialsById.containsKey(
                                              materialId,
                                            )) {
                                          final mat =
                                              materialsById[materialId]!;
                                          materialLabel =
                                              '${mat.name} (${mat.color})';
                                        } else {
                                          materialLabel =
                                              usage['materialName']
                                                  ?.toString() ??
                                              materialId ??
                                              l10n.materialFallback;
                                        }

                                        return Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      materialLabel,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    l10n.historyMaterialUsageWeightLabel(
                                                      weight.toString(),
                                                    ),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Colors.white60,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (idx <
                                                data.materialUsages.length - 1)
                                              const Divider(
                                                height: 1,
                                                color: Colors.white12,
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if ((data.additionalCostNote ?? '')
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              collapsedBackgroundColor: Colors.transparent,
                              iconColor: Colors.white70,
                              collapsedIconColor: Colors.white54,
                              title: Text(
                                l10n.additionalCostNoteLabel,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      data.additionalCostNote!,
                                      key: ValueKey<String>(
                                        '$itemKeyPrefix.additionalCostNote',
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _row(
  BuildContext context,
  String label,
  num value, {
  Key? key,
  required GeneralSettingsModel currencySettings,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          key: key,
          formatCurrencyValue(
            value,
            currencySymbol: currencySettings.currencySymbol,
            currencyPosition: currencySettings.currencyPosition,
            currencySpacing: currencySettings.currencySpacing,
          ),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ],
    ),
  );
}
