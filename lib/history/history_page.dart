import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/history/components/history_export_options_sheet.dart';
import 'package:threed_print_cost_calculator/history/components/history_export_preview_sheet.dart';
import 'package:threed_print_cost_calculator/history/components/history_overflow_hint.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_upsell_helper.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'provider/history_paged_notifier.dart';

import 'components/history_empty_state.dart';
import 'components/history_teaser.dart';
import 'components/history_list_view.dart';
import 'components/history_search_bar.dart';
import 'hooks/history_search_query.dart';

enum HistoryPageMode { full, teaser }

const _overflowHintPreferenceKey = 'history_overflow_hint_seen_v2';
const _overflowMenuOpenedPreferenceKey = 'history_overflow_menu_opened_v1';
const _overflowHintDuration = Duration(seconds: 4);

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

    if (mode == HistoryPageMode.teaser) {
      return HistoryTeaser(
        onUpgradePressed: () => _showTeaserPaywall(
          context,
          ref: ref,
          isPremium: policy.isPremium,
          source: 'history_teaser_primary',
        ),
        onExportPreviewPressed: () => _showTeaserPreview(
          context,
          ref: ref,
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

    final prefs = ref.read(sharedPreferencesProvider);
    final controller = useTextEditingController(text: paged.query);
    final scrollController = useScrollController();
    final showOverflowHint = useState(false);
    final overflowHintTimer = useRef<Timer?>(null);

    useHistorySearchQuery(ref: ref, controller: controller);

    Future<void> markOverflowHintSeen() async {
      if (prefs.getBool(_overflowHintPreferenceKey) == true) return;
      await prefs.setBool(_overflowHintPreferenceKey, true);
    }

    Future<void> markOverflowMenuOpened() async {
      if (prefs.getBool(_overflowMenuOpenedPreferenceKey) == true) return;
      await prefs.setBool(_overflowMenuOpenedPreferenceKey, true);
      AppAnalytics.safeLog(() => AppAnalytics.log('history_overflow_opened'));
    }

    void dismissOverflowHint() {
      if (!showOverflowHint.value) return;
      overflowHintTimer.value?.cancel();
      showOverflowHint.value = false;
    }

    useEffect(() {
      var disposed = false;

      Future<void> maybeShowOverflowHint() async {
        if (paged.items.isEmpty) return;

        final hasSeenHint = prefs.getBool(_overflowHintPreferenceKey) ?? false;
        final hasOpenedMenu =
            prefs.getBool(_overflowMenuOpenedPreferenceKey) ?? false;
        if (hasSeenHint || hasOpenedMenu || showOverflowHint.value) return;

        await markOverflowHintSeen();
        AppAnalytics.safeLog(
          () => AppAnalytics.log('history_overflow_hint_shown'),
        );
        if (disposed) return;

        showOverflowHint.value = true;
        overflowHintTimer.value?.cancel();
        overflowHintTimer.value = Timer(_overflowHintDuration, () {
          if (!disposed) {
            showOverflowHint.value = false;
          }
        });
      }

      unawaited(maybeShowOverflowHint());

      return () {
        disposed = true;
        overflowHintTimer.value?.cancel();
      };
    }, [paged.items.length]);

    // Load first page on mount — schedule after the first frame to avoid
    // modifying providers during the widget build lifecycle.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(historyPagedProvider.notifier).refreshIfNeeded();
      });
      return null;
    }, [appRefreshTick]);

    // Infinite scroll: listen to scroll controller and load more when near bottom
    useEffect(() {
      void scrollListener() {
        final sc = scrollController;
        if (!sc.hasClients) return;
        final max = sc.position.maxScrollExtent;
        final current = sc.position.pixels;

        // Trigger when within 200px of bottom
        const threshold = 200.0;
        if (current >= (max - threshold)) {
          final notifier = ref.read(historyPagedProvider.notifier);
          final state = ref.read(historyPagedProvider);
          if (!state.isLoading && state.hasMore && !hasReachedHistoryLimit) {
            notifier.loadMore();
          }
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

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
                      ? () => _showExportOptions(context, ref)
                      : null,
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: showOverflowHint.value
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
                    await markOverflowMenuOpened();
                    dismissOverflowHint();
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

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return HistoryExportOptionsSheet(
          onExportSelected: (range) async {
            await _exportHistoryRange(ref, l10n, range);
          },
        );
      },
    );
  }

  Future<void> _exportHistoryRange(
    WidgetRef ref,
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

    // Use mixed history export to handle both single-print and batch quotes
    await ref
        .read(csvUtilsProvider)
        .exportMixedHistoryForRange(
          range,
          shareText: l10n.mixedHistoryExportShareText,
        );
    AppAnalytics.safeLog(() => AppAnalytics.exportUsed('history'));
  }

  Future<void> _showTeaserPreview(
    BuildContext context, {
    required WidgetRef ref,
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
      builder: (sheetContext) {
        return HistoryExportPreviewSheet(
          csvPreview: csvPreview,
          onDownloadPressed: () async {
            Navigator.of(sheetContext).pop();
            await _showTeaserPaywall(
              context,
              ref: ref,
              isPremium: isPremium,
              source: source,
            );
          },
        );
      },
    );
  }

  Future<void> _showTeaserPaywall(
    BuildContext context, {
    required WidgetRef ref,
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
