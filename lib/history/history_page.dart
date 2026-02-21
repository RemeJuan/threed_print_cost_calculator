import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'provider/history_paged_notifier.dart';

import 'components/history_item.dart';
import 'components/history_toolbar.dart';

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(context, ref) {
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
        ref.read(historyPagedProvider.notifier).refresh();
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
            return Center(child: Text('Error loading history: ${paged.error}'));
          }

          return CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: HistoryToolbar(
                    controller: controller,
                    onExportPressed: () {
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
                                    'Export Prints',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ),
                                ListTile(
                                  title: const Text('All'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await ref
                                        .read(csvUtilsProvider)
                                        .exportForRange(ExportRange.all);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Last 7 days'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await ref
                                        .read(csvUtilsProvider)
                                        .exportForRange(ExportRange.last7Days);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Last 30 days'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await ref
                                        .read(csvUtilsProvider)
                                        .exportForRange(ExportRange.last30Days);
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: paged.items.length,
                itemBuilder: (_, index) {
                  final record = paged.items[index];
                  final item = record.value;

                  final data = HistoryModel.fromMap(item);

                  return HistoryItem(dbKey: record.key.toString(), data: data);
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('No more records'),
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
