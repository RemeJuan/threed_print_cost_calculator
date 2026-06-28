import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/history/components/history_export_options_sheet.dart';
import 'package:threed_print_cost_calculator/history/components/history_export_preview_sheet.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_upsell_helper.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

class HistoryPageActions {
  const HistoryPageActions({required this.ref});

  final WidgetRef ref;

  void showExportOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => HistoryExportOptionsSheet(
        onExportSelected: (range) async => exportHistoryRange(l10n, range),
      ),
    );
  }

  Future<void> exportHistoryRange(
    AppLocalizations l10n,
    ExportRange range,
  ) async {
    final policy = ref.read(premiumAccessPolicyProvider);
    if (!await requirePremium(
      ref.read(paywallPresenterProvider),
      policy.bulkHistoryExport(),
      purchaseSource: 'history_export',
      recheck: () => Future.value(
        ref.read(premiumAccessPolicyProvider).bulkHistoryExport().allowed,
      ),
    )) {
      return;
    }

    await ref
        .read(csvUtilsProvider)
        .exportMixedHistoryForRange(
          range,
          shareText: l10n.mixedHistoryExportShareText,
        );
    AppAnalytics.safeLog(() => AppAnalytics.exportUsed('history'));
  }

  Future<void> showTeaserPreview(
    BuildContext context, {
    required bool isPremium,
    required String source,
  }) async {
    AppAnalytics.safeLog(
      () => AppAnalytics.premiumFeatureTapped(
        'history',
        isPro: isPremium,
        source: source,
      ),
    );

    final l10n = AppLocalizations.of(context)!;
    final csvPreview = [
      l10n.historyCsvHeader,
      '"Benchy",19.25,12.50,3.00,2.50,123,06:20',
      '"Prusa MK4S",24.10,15.75,3.40,2.75,142,05:10',
    ].join('\n');

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => HistoryExportPreviewSheet(
        csvPreview: csvPreview,
        onDownloadPressed: () async {
          Navigator.of(sheetContext).pop();
          await showTeaserPaywall(
            context,
            isPremium: isPremium,
            source: source,
          );
        },
      ),
    );
  }

  Future<void> showTeaserPaywall(
    BuildContext context, {
    required bool isPremium,
    required String source,
  }) async {
    AppAnalytics.safeLog(
      () => AppAnalytics.premiumFeatureTapped(
        'history',
        isPro: isPremium,
        source: source,
      ),
    );
    await ref
        .read(paywallPresenterProvider)
        .present(
          'pro',
          triggerFeature: 'history',
          purchaseSource: source,
          source: source,
        );
  }
}
