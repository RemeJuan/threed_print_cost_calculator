import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'provider/history_paged_notifier.dart';

import 'components/history_export_preview_sheet.dart';
import 'components/history_teaser_state.dart';
import 'components/history_item.dart';
import 'components/history_upsell_banner.dart';
import 'components/history_toolbar.dart';

enum HistoryPageMode { full, teaser }

const _overflowHintPreferenceKey = 'history_overflow_hint_seen_v2';
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

    if (mode == HistoryPageMode.teaser) {
      return HistoryTeaserState(
        onUpgradePressed: () => _showPaywall(context),
        onExportPreviewPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (sheetContext) {
              return HistoryExportPreviewSheet(
                csvPreview: generateSampleCsvPreview(
                  csvHeader: l10n.historyCsvHeader,
                ),
                onDownloadPressed: () {
                  Navigator.pop(sheetContext);
                  _showPaywall(context);
                },
              );
            },
          );
        },
      );
    }

    // Providers will handle reading the DB and filtering via historyPagedProvider
    final pagedNow = ref.read(historyPagedProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final controller = useTextEditingController(text: pagedNow.query);
    final scrollController = useScrollController();
    final showOverflowHint = useState(false);
    final shouldShowUpsell = ref.watch(shouldShowProPromotionProvider);

    // Debounce controller and push updates to the `historyPagedProvider` by calling setQuery.
    final debounceTimer = useRef<Timer?>(null);
    final overflowHintTimer = useRef<Timer?>(null);
    const debounceDuration = Duration(milliseconds: 300);

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
        final hasSeenHint = prefs.getBool(_overflowHintPreferenceKey) ?? false;
        if (hasSeenHint) return;

        await prefs.setBool(_overflowHintPreferenceKey, true);
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
    }, const []);

    // Load first page on mount — schedule after the first frame to avoid
    // modifying providers during the widget build lifecycle.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(historyPagedProvider.notifier).refreshIfNeeded();
      });
      return null;
    }, const []);

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
      body: HookConsumer(
        builder: (context, ref, child) {
          final paged = ref.watch(historyPagedProvider);

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
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: HistoryToolbar(
                    controller: controller,
                    onExportPressed: () => _showExportOptions(context, ref),
                  ),
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
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.historyEmptyTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.historyEmptyDescription,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          if (shouldShowUpsell) ...[
                            const SizedBox(height: 16),
                            HistoryUpsellBanner(
                              onTap: () =>
                                  _showHistoryUpsellPaywall(context, ref),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: paged.items.length,
                  itemBuilder: (_, index) {
                    final entry = paged.items[index];
                    return HistoryItem(
                      dbKey: entry.key.toString(),
                      data: entry.model,
                      onHistoryLoaded: onHistoryLoaded,
                      onOverflowMenuOpened: dismissOverflowHint,
                    );
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

  void _showPaywall(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const Subscriptions(),
    );
  }

  Future<void> _showHistoryUpsellPaywall(
    BuildContext context,
    WidgetRef ref,
  ) async {
    AppAnalytics.safeLog(() => AppAnalytics.premiumFeatureTapped('history'));
    AppAnalytics.safeLog(() => AppAnalytics.paywallShown('history'));
    await ref.read(paywallPresenterProvider).present('pro');
  }
}
