import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/history/components/history_full_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'components/history_teaser.dart';
import 'hooks/history_page_actions.dart';
import 'provider/history_paged_notifier.dart';

enum HistoryPageMode { full, teaser }

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({
    super.key,
    this.mode = HistoryPageMode.full,
    this.onHistoryLoaded,
  });

  final HistoryPageMode mode;
  final Future<void> Function()? onHistoryLoaded;

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final appRefreshTick = ref.watch(appRefreshProvider);
    final paged = ref.watch(historyPagedProvider);
    final policy = ref.watch(premiumAccessPolicyProvider);

    final actions = HistoryPageActions(ref: ref);

    if (mode == HistoryPageMode.teaser) {
      return HistoryTeaser(
        onUpgradePressed: () => actions.showTeaserPaywall(
          context,
          isPremium: policy.isPremium,
          source: 'history_teaser_primary',
        ),
        onExportPreviewPressed: () => actions.showTeaserPreview(
          context,
          isPremium: policy.isPremium,
          source: 'history_teaser_secondary',
        ),
      );
    }
    return HistoryFullPage(
      l10n: l10n,
      paged: paged,
      policy: policy,
      appRefreshTick: appRefreshTick,
      actions: actions,
      onHistoryLoaded: onHistoryLoaded,
    );
  }
}
