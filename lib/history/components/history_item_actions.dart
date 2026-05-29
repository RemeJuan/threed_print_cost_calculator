import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_upsell_helper.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/history/provider/history_providers.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

typedef HistoryItemExportCsv =
    Future<void> Function(
      List<HistoryModel> items, {
      required String csvHeader,
      required String shareText,
    });

class HistoryItemActionsController {
  const HistoryItemActionsController({
    required this.dbKey,
    required this.data,
    required this.exportCsv,
    this.onHistoryLoaded,
    this.deleteHistoryEntry,
  });

  final String dbKey;
  final HistoryModel data;
  final Future<void> Function()? onHistoryLoaded;
  final Future<void> Function(WidgetRef ref, String dbKey)? deleteHistoryEntry;
  final HistoryItemExportCsv exportCsv;

  Future<void> exportEntry(
    BuildContext context,
    WidgetRef ref,
    AppLogger logger,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.read(premiumAccessPolicyProvider);
    final access = data.batchQuote
        ? policy.batchExport()
        : policy.historyExport();
    if (!await requirePremium(
      ref.read(paywallPresenterProvider),
      access,
      purchaseSource: 'history_export_entry',
    )) {
      return;
    }

    try {
      if (data.batchQuote) {
        // Use batch-specific export for batch quotes
        final csvUtils = ref.read(csvUtilsProvider);
        await csvUtils.exportBatchQuote(
          data,
          shareText: l10n.batchQuoteExportShareText,
        );
      } else {
        // Use existing single-print export
        await exportCsv(
          [data],
          csvHeader: l10n.historyCsvHeader,
          shareText: l10n.historyExportShareText,
        );
      }
      AppAnalytics.safeLog(() => AppAnalytics.exportUsed('job'));
      if (!context.mounted) return;
      BotToast.showText(text: l10n.exportSuccess);
    } catch (e, st) {
      logger.error(
        AppLogCategory.ui,
        'History export failed',
        context: {'exportType': 'job'},
        error: e,
        stackTrace: st,
      );
      if (!context.mounted) return;
      BotToast.showText(text: l10n.exportError);
    }
  }

  Future<void> deleteEntry(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteDialogTitle),
        content: Text(l10n.deleteDialogContent),
        actions: [
          AppTertiaryButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            label: l10n.cancelButton,
          ),
          AppTertiaryButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            label: l10n.deleteButton,
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (deleteHistoryEntry != null) {
      await deleteHistoryEntry!(ref, dbKey);
      return;
    }

    final dbHelpers = ref.read(dbHelpersProvider(DBName.history));
    try {
      await dbHelpers.deleteRecord(dbKey);
    } catch (_) {
      if (!context.mounted) return;
      BotToast.showText(
        text: AppLocalizations.of(context)!.deleteRecordErrorMessage,
      );
      return;
    }
    ref.read(historyPagedProvider.notifier).refresh();
    ref.invalidate(historyRecordsProvider);
  }

  Future<void> loadEntry(WidgetRef ref) async {
    final didLoad = await ref
        .read(calculatorProvider.notifier)
        .loadFromHistory(HistoryEntry(key: dbKey, model: data));
    if (!didLoad) return;
    await onHistoryLoaded?.call();
  }
}

class HistoryItemActions extends ConsumerWidget {
  const HistoryItemActions({
    required this.dbKey,
    required this.data,
    required this.itemKeyPrefix,
    required this.exportCsv,
    this.onHistoryLoaded,
    this.onOverflowMenuOpened,
    this.deleteHistoryEntry,
    super.key,
  });

  final String dbKey;
  final HistoryModel data;
  final String itemKeyPrefix;
  final Future<void> Function()? onHistoryLoaded;
  final VoidCallback? onOverflowMenuOpened;
  final Future<void> Function(WidgetRef ref, String dbKey)? deleteHistoryEntry;
  final HistoryItemExportCsv exportCsv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logger = ref.read(appLoggerProvider);
    final controller = HistoryItemActionsController(
      dbKey: dbKey,
      data: data,
      onHistoryLoaded: onHistoryLoaded,
      deleteHistoryEntry: deleteHistoryEntry,
      exportCsv: exportCsv,
    );

    return PopupMenuButton<_HistoryItemAction>(
      key: ValueKey<String>('$itemKeyPrefix.menu'),
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      icon: const SizedBox.square(
        dimension: 44,
        child: Center(
          child: Icon(Icons.more_horiz, color: ICON_PRIMARY, size: 22),
        ),
      ),
      padding: EdgeInsets.zero,
      splashRadius: 24,
      onOpened: onOverflowMenuOpened,
      onSelected: (action) async {
        switch (action) {
          case _HistoryItemAction.edit:
            await controller.loadEntry(ref);
            return;
          case _HistoryItemAction.export:
            await controller.exportEntry(context, ref, logger);
            return;
          case _HistoryItemAction.delete:
            await controller.deleteEntry(context, ref);
            return;
        }
      },
      itemBuilder: (context) => [
        if (!data.batchQuote)
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
              const Icon(Icons.delete_outline, size: 20, color: STATUS_ERROR),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  l10n.deleteButton,
                  style: const TextStyle(color: STATUS_ERROR),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _HistoryItemAction { edit, export, delete }
