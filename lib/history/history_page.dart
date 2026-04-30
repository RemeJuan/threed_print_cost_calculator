import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/history/components/history_export_preview_sheet.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'provider/history_paged_notifier.dart';

import 'components/history_empty_state.dart';
import 'components/history_teaser_state.dart';
import 'components/history_list_view.dart';
import 'components/history_search_bar.dart';
import 'components/history_upsell_banner.dart';

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

    if (mode == HistoryPageMode.teaser) {
      final isPremium = ref.watch(isPremiumProvider);
      return HistoryTeaserState(
        onUpgradePressed: () => _showTeaserPaywall(
          context,
          ref: ref,
          isPremium: isPremium,
          source: 'history_teaser_primary',
        ),
        onExportPreviewPressed: () => _showTeaserPreview(
          context,
          ref: ref,
          isPremium: isPremium,
          source: 'history_teaser_secondary',
        ),
      );
    }

    final prefs = ref.read(sharedPreferencesProvider);
    final controller = useTextEditingController(text: paged.query);
    final scrollController = useScrollController();
    final showOverflowHint = useState(false);
    final shouldShowUpsell = ref.watch(shouldShowProPromotionProvider);

    // Debounce controller and push updates to the `historyPagedProvider` by calling setQuery.
    final debounceTimer = useRef<Timer?>(null);
    final overflowHintTimer = useRef<Timer?>(null);
    const debounceDuration = Duration(milliseconds: 300);

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
      void listener() {
        debounceTimer.value?.cancel();
        debounceTimer.value = Timer(debounceDuration, () {
          ref.read(historyPagedProvider.notifier).setQuery(controller.text);
        });
      }

      controller.addListener(listener);

      return () {
        controller.removeListener(listener);
        debounceTimer.value?.cancel();
        overflowHintTimer.value?.cancel();
      };
    }, [controller]);

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
          if (!state.isLoading && state.hasMore) {
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
                  onExportPressed: () => _showExportOptions(context, ref),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: showOverflowHint.value
                      ? Padding(
                          key: const ValueKey<String>('history.overflow.hint'),
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(l10n.historyOverflowHint),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (!showEmptyState && shouldShowUpsell)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: HistoryUpsellBanner(
                      onTap: () => _showHistoryUpsellPaywall(context, ref),
                    ),
                  ),
                ),
              if (showEmptyState)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: HistoryEmptyState(
                    showUpsell: shouldShowUpsell,
                    onUpsellTap: () => _showHistoryUpsellPaywall(context, ref),
                  ),
                )
              else
                HistoryListView(
                  items: paged.items,
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
                      if (!paged.hasMore)
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
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.historyExportMenuTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                title: Text(l10n.historyExportRangeAll),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(csvUtilsProvider)
                      .exportForRange(
                        ExportRange.all,
                        csvHeader: l10n.historyCsvHeader,
                        shareText: l10n.historyExportShareText,
                      );
                  AppAnalytics.safeLog(
                    () => AppAnalytics.exportUsed('history'),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.historyExportRangeLast7Days),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(csvUtilsProvider)
                      .exportForRange(
                        ExportRange.last7Days,
                        csvHeader: l10n.historyCsvHeader,
                        shareText: l10n.historyExportShareText,
                      );
                  AppAnalytics.safeLog(
                    () => AppAnalytics.exportUsed('history'),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.historyExportRangeLast30Days),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(csvUtilsProvider)
                      .exportForRange(
                        ExportRange.last30Days,
                        csvHeader: l10n.historyCsvHeader,
                        shareText: l10n.historyExportShareText,
                      );
                  AppAnalytics.safeLog(
                    () => AppAnalytics.exportUsed('history'),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
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

  Future<void> _showHistoryUpsellPaywall(
    BuildContext context,
    WidgetRef ref,
  ) async {
    AppAnalytics.safeLog(
      () => AppAnalytics.premiumFeatureTapped('history', isPro: false),
    );
    await ref
        .read(paywallPresenterProvider)
        .present(
          'pro',
          triggerFeature: 'history',
          purchaseSource: 'history',
          source: 'premium_feature',
          launchCount:
              ref.read(sharedPreferencesProvider).getInt('run_count') ?? 0,
        );
  }
}
