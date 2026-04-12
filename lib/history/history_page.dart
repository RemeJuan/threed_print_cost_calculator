import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'provider/history_paged_notifier.dart';

import 'components/history_export_preview_sheet.dart';
import 'components/history_teaser_state.dart';
import 'components/history_item.dart';
import 'components/history_toolbar.dart';

enum HistoryPageMode { full, teaser }

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key, this.mode = HistoryPageMode.full});

  final HistoryPageMode mode;

  @override
  Widget build(context, ref) {
    final l10n = S.of(context);

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
    final controller = useTextEditingController(text: pagedNow.query);
    final scrollController = useScrollController();

    // Debounce controller and push updates to the `historyPagedProvider` by calling setQuery.
    final debounceTimer = useRef<Timer?>(null);
    const debounceDuration = Duration(milliseconds: 300);

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
      };
    }, [controller]);

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
              SliverList.builder(
                itemCount: paged.items.length,
                itemBuilder: (_, index) {
                  final entry = paged.items[index];
                  return HistoryItem(
                    dbKey: entry.key.toString(),
                    data: entry.model,
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
    final l10n = S.of(context);

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
}
