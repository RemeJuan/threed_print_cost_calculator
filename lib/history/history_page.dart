import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/history/components/history_overflow_hint.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'components/history_empty_state.dart';
import 'components/history_list_view.dart';
import 'components/history_search_bar.dart';
import 'components/history_teaser.dart';
import 'hooks/history_overflow_hint.dart';
import 'hooks/history_page_actions.dart';
import 'hooks/history_search_query.dart';
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

    final historyLimit = policy.historyLimit;
    final isHistoryLimited = !policy.isPremium && historyLimit != null;
    final hasReachedHistoryLimit =
        isHistoryLimited && paged.items.length >= historyLimit;
    final visibleItems = isHistoryLimited
        ? paged.items.take(historyLimit).toList(growable: false)
        : paged.items;

    final controller = useTextEditingController(text: paged.query);
    final scrollController = useScrollController();
    final overflowHint = useHistoryOverflowHint(
      ref: ref,
      itemCount: paged.items.length,
    );

    useHistorySearchQuery(ref: ref, controller: controller);

    useEffect(() {
      final notifier = ref.read(historyPagedProvider.notifier);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.refreshIfNeeded();
      });
      return null;
    }, [appRefreshTick]);

    useEffect(() {
      void scrollListener() {
        if (!scrollController.hasClients) return;
        final max = scrollController.position.maxScrollExtent;
        final current = scrollController.position.pixels;
        const threshold = 200.0;
        if (current >= (max - threshold)) {
          final notifier = ref.read(historyPagedProvider.notifier);
          final state = ref.read(historyPagedProvider);
          if (!state.isLoading && state.hasMore) {
            notifier.loadMore();
          }
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController, hasReachedHistoryLimit]);

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (paged.isLoading && paged.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paged.error != null && paged.items.isEmpty) {
            return Center(
              child: Text(l10n.historyLoadError(paged.error.toString())),
            );
          }

          final showEmptyState =
              paged.items.isEmpty &&
              paged.query.trim().isEmpty &&
              paged.hasLoadedOnce &&
              !paged.isLoading;

          return CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: HistorySearchBar(
                  controller: controller,
                  onExportPressed: policy.bulkHistoryExport().allowed
                      ? () => actions.showExportOptions(context)
                      : null,
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: overflowHint.showOverflowHint.value
                      ? HistoryOverflowHint(
                          key: const ValueKey<String>('history.overflow.hint'),
                          message: l10n.historyOverflowHint,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (showEmptyState)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: const HistoryEmptyState(),
                )
              else
                HistoryListView(
                  items: visibleItems,
                  onHistoryLoaded: onHistoryLoaded,
                  onOverflowMenuOpened: () async {
                    await overflowHint.markOverflowMenuOpened();
                    overflowHint.dismissOverflowHint();
                  },
                ),
              SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      if (paged.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: CircularProgressIndicator(),
                        ),
                      if (hasReachedHistoryLimit)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(l10n.historyUpsellDescription),
                        )
                      else if (!paged.hasMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(l10n.historyNoMoreRecords),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
