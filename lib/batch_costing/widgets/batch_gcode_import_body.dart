import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_import_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_gcode_import_details_sheet.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_import_file_row.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_single_import_view.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class BatchGcodeImportBody extends ConsumerWidget {
  const BatchGcodeImportBody({
    super.key,
    required this.rows,
    required this.singleImport,
    required this.singleImportError,
    required this.loading,
    required this.onPickFiles,
    this.onRemoveSingleImport,
    this.onApplySingleImportDetails,
    this.onConfirmSingleImport,
    this.onRemoveRow,
    this.onApplyDetails,
  });

  final List<BatchImportRow> rows;
  final BatchSingleImport? singleImport;
  final String? singleImportError;
  final bool loading;
  final VoidCallback onPickFiles;
  final VoidCallback? onRemoveSingleImport;
  final VoidCallback? onApplySingleImportDetails;
  final VoidCallback? onConfirmSingleImport;
  final void Function(BatchImportRow)? onRemoveRow;
  final void Function(BatchImportRow)? onApplyDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stateItems = ref.watch(batchCostingProvider).items;
    final hasReady = rows.any((row) => row.status == ImportStatus.ready);
    final hasNeedsDetails = rows.any(
      (row) => row.status == ImportStatus.needsDetails,
    );
    final allDone =
        !loading &&
        rows.isNotEmpty &&
        rows.every((row) => row.status != ImportStatus.importing);

    BatchCostingItem? itemForRow(BatchImportRow row) {
      if (row.batchItemId == null) return null;
      for (final item in stateItems) {
        if (item.id == row.batchItemId) return item;
      }
      return null;
    }

    return Padding(
      padding: const EdgeInsets.all(kAppSpace16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.batchGcodeImportBody),
          const SizedBox(height: kAppSpace16),
          AppPrimaryButton(
            onPressed: loading ? null : onPickFiles,
            icon: const Icon(Icons.folder_open),
            label: l10n.batchGcodeImportPickButton,
          ),
          const SizedBox(height: kAppSpace8),
          if (singleImport == null)
            Text(
              l10n.batchGcodeImportQuantityHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: kAppSpace16),
          Expanded(
            child: singleImport != null
                ? BatchSingleImportView(
                    singleImport: singleImport!,

                    l10n: l10n,
                    onRemove: onRemoveSingleImport ?? () {},
                    onApplyDetails: onApplySingleImportDetails ?? () {},
                  )
                : rows.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: kAppSpace8),
                    itemBuilder: (context, index) => BatchImportFileRow(
                      row: rows[index],
                      item: itemForRow(rows[index]),
                      l10n: l10n,
                      onShowDetails: () => showImportDetailsSheet(
                        context,
                        itemForRow(rows[index])!,
                      ),
                      onRemove: () => onRemoveRow?.call(rows[index]),
                      onApply: () => onApplyDetails?.call(rows[index]),
                    ),
                  ),
          ),
          if (singleImport != null)
            Padding(
              padding: const EdgeInsets.only(top: kAppSpace16),
              child: AppPrimaryButton(
                onPressed: singleImport!.canContinue
                    ? onConfirmSingleImport
                    : null,
                icon: const Icon(Icons.playlist_add),
                label: l10n.batchGcodeImportAddButton,
              ),
            )
          else if (singleImportError != null)
            Padding(
              padding: const EdgeInsets.only(top: kAppSpace16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    singleImportError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: kAppSpace12),
                  AppTertiaryButton(
                    onPressed: onPickFiles,
                    label: l10n.batchGcodeImportRetryButton,
                  ),
                ],
              ),
            )
          else if (allDone && hasReady && !hasNeedsDetails)
            Padding(
              padding: const EdgeInsets.only(top: kAppSpace16),
              child: AppPrimaryButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BatchCostingPage(),
                    ),
                  );
                },
                label: l10n.batchGcodeImportContinueButton,
              ),
            )
          else if (allDone && rows.isNotEmpty && !hasReady && !hasNeedsDetails)
            Padding(
              padding: const EdgeInsets.only(top: kAppSpace16),
              child: Row(
                children: [
                  AppTertiaryButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  const SizedBox(width: kAppSpace8),
                  AppTertiaryButton(
                    onPressed: onPickFiles,
                    label: l10n.batchGcodeImportRetryButton,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void showImportDetailsSheet(BuildContext context, BatchCostingItem item) {
  final l10n = AppLocalizations.of(context)!;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BatchGCodeImportDetailsSheet(item: item, l10n: l10n),
  );
}
