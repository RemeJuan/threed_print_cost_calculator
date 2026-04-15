import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/history/provider/history_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/label_utils.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_providers.dart';

class HistoryItem extends HookConsumerWidget {
  final String dbKey;
  final HistoryModel data;
  final Future<void> Function()? onHistoryLoaded;
  final VoidCallback? onOverflowMenuOpened;

  const HistoryItem({
    required this.dbKey,
    required this.data,
    this.onHistoryLoaded,
    this.onOverflowMenuOpened,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final materialsById = ref.watch(materialsByIdProvider);
    final logger = ref.read(appLoggerProvider);
    final itemKeyPrefix = 'history.item.${data.name}';

    Future<void> exportEntry() async {
      try {
        await exportCSVFile(
          [data],
          csvHeader: l10n.historyCsvHeader,
          shareText: l10n.historyExportShareText,
        );
        AppAnalytics.safeLog(() => AppAnalytics.exportUsed('job'));
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
      } catch (e, st) {
        logger.error(
          AppLogCategory.ui,
          'History export failed',
          context: {'exportType': 'job'},
          error: e,
          stackTrace: st,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportError)));
      }
    }

    Future<void> deleteEntry() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deleteDialogTitle),
          content: Text(l10n.deleteDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.deleteButton),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final dbHelpers = ref.read(dbHelpersProvider(DBName.history));
      await dbHelpers.deleteRecord(dbKey);
      ref.read(historyPagedProvider.notifier).refresh();
      ref.invalidate(historyRecordsProvider);
    }

    Future<void> loadEntry() async {
      final didLoad = await ref
          .read(calculatorProvider.notifier)
          .loadFromHistory(HistoryEntry(key: dbKey, model: data));
      if (!didLoad) return;
      await onHistoryLoaded?.call();
    }

    return Slidable(
      key: ValueKey(dbKey),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) async => deleteEntry(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: l10n.deleteButton,
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
                    PopupMenuButton<_HistoryItemAction>(
                      key: ValueKey<String>('$itemKeyPrefix.menu'),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).showMenuTooltip,
                      icon: const SizedBox.square(
                        dimension: 44,
                        child: Center(
                          child: Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      splashRadius: 24,
                      onOpened: onOverflowMenuOpened,
                      onSelected: (action) async {
                        switch (action) {
                          case _HistoryItemAction.edit:
                            await loadEntry();
                            return;
                          case _HistoryItemAction.export:
                            await exportEntry();
                            return;
                          case _HistoryItemAction.delete:
                            await deleteEntry();
                            return;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<_HistoryItemAction>(
                          value: _HistoryItemAction.edit,
                          child: Row(
                            children: [
                              const Icon(Icons.calculate, size: 20),
                              const SizedBox(width: 12),
                              Flexible(child: Text(l10n.historyLoadAction)),
                            ],
                          ),
                        ),
                        PopupMenuItem<_HistoryItemAction>(
                          value: _HistoryItemAction.export,
                          child: Row(
                            children: [
                              const Icon(Icons.ios_share, size: 20),
                              const SizedBox(width: 12),
                              Flexible(child: Text(l10n.exportButton)),
                            ],
                          ),
                        ),
                        PopupMenuItem<_HistoryItemAction>(
                          value: _HistoryItemAction.delete,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  l10n.deleteButton,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (data.materialUsages.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formatCountLabel(
                            l10n.materialsCountLabel(
                              data.materialUsages.length,
                            ),
                            data.materialUsages.length,
                          ),
                        ),
                      ),
                    if (data.materialUsages.length > 1)
                      const SizedBox(width: 8),
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
                  key: ValueKey<String>('$itemKeyPrefix.electricityCost'),
                ),
                _row(
                  context,
                  l10n.filamentCostLabel,
                  data.filamentCost,
                  key: ValueKey<String>('$itemKeyPrefix.filamentCost'),
                ),
                _row(
                  context,
                  l10n.labourCostLabel,
                  data.labourCost,
                  key: ValueKey<String>('$itemKeyPrefix.labourCost'),
                ),
                _row(
                  context,
                  l10n.riskCostLabel,
                  data.riskCost,
                  key: ValueKey<String>('$itemKeyPrefix.riskCost'),
                ),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      l10n.totalCostLabel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      key: ValueKey<String>('$itemKeyPrefix.totalCost'),
                      data.totalCost.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
                      timeLabel = '${h}h ${m}m';
                    } catch (_) {
                      timeLabel = data.timeHours;
                    }

                    final summary =
                        '${weightKg.toStringAsFixed(2)} kg • $timeLabel • ${data.printer} • ${data.material}';

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
                                                    '${weight}g',
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

enum _HistoryItemAction { edit, export, delete }

Widget _row(BuildContext context, String label, num value, {Key? key}) {
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
          value.toStringAsFixed(2),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ],
    ),
  );
}
