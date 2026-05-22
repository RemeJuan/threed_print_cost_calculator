import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_providers.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_actions.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_cost_rows.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_header.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_material_breakdown.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_slidable_wrapper.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_summary.dart';
import 'package:threed_print_cost_calculator/history/components/batch_history_item.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

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
    final materialsById = ref.watch(materialsByIdProvider);
    final itemKeyPrefix = 'history.item.${data.name}';
    final actionsController = HistoryItemActionsController(
      dbKey: dbKey,
      data: data,
      onHistoryLoaded: onHistoryLoaded,
      deleteHistoryEntry: deleteHistoryEntry,
      exportCsv: exportCsv,
    );

    return HistoryItemSlidableWrapper(
      dbKey: dbKey,
      deleteLabel: l10n.deleteButton,
      onDelete: () => actionsController.deleteEntry(context, ref),
      child: data.batchQuote
          ? AppSurfaceCard(
              padding: const EdgeInsets.all(8),
              child: BatchHistoryItem(
                dbKey: dbKey,
                data: data,
                itemKeyPrefix: itemKeyPrefix,
                onOverflowMenuOpened: onOverflowMenuOpened,
                deleteHistoryEntry: deleteHistoryEntry,
                exportCsv: exportCsv,
              ),
            )
          : AppSurfaceCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HistoryItemHeader(
                    dbKey: dbKey,
                    data: data,
                    itemKeyPrefix: itemKeyPrefix,
                    onHistoryLoaded: onHistoryLoaded,
                    onOverflowMenuOpened: onOverflowMenuOpened,
                    deleteHistoryEntry: deleteHistoryEntry,
                    exportCsv: exportCsv,
                  ),
                  const SizedBox(height: 8),
                  HistoryItemCostRows(data: data, itemKeyPrefix: itemKeyPrefix),
                  const SizedBox(height: 4),
                  const Divider(),
                  const SizedBox(height: 4),
                  HistoryItemSummary(data: data, itemKeyPrefix: itemKeyPrefix),
                  if (data.materialUsages.isNotEmpty)
                    HistoryItemMaterialBreakdown(
                      materialUsages: data.materialUsages,
                      materialsById: materialsById,
                    ),
                ],
              ),
            ),
    );
  }
}
