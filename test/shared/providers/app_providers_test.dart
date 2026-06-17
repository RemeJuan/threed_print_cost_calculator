import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  group('AppRefreshNotifier', () {
    test('refresh() increments state in pure dart context', () {
      // SchedulerBinding unavailable in pure dart test
      // -> falls through to immediate increment
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(appRefreshProvider), 0);
      container.read(appRefreshProvider.notifier).refresh();
      expect(container.read(appRefreshProvider), 1);
      container.read(appRefreshProvider.notifier).refresh();
      expect(container.read(appRefreshProvider), 2);
    });

    testWidgets('refresh() during build defers and does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: _RefreshDuringBuild(key: const Key('refreshDuringBuild')),
        ),
      );

      // No FlutterError about markNeedsBuild/setState during build
      expect(tester.takeException(), isNull);

      final container = ProviderScope.containerOf(
        tester.element(find.byKey(const Key('refreshDuringBuild'))),
        listen: false,
      );
      // Deferred callback fires in pumpWidget's internal extra frames
      expect(container.read(appRefreshProvider), 1);

      await tester.pump();
      // No duplicate increment — _refreshQueued coalesced correctly
      expect(container.read(appRefreshProvider), 1);
    });

    testWidgets('multiple refresh() during build coalesce', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: _MultiRefreshDuringBuild(
            key: const Key('multiRefreshDuringBuild'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      final container = ProviderScope.containerOf(
        tester.element(find.byKey(const Key('multiRefreshDuringBuild'))),
        listen: false,
      );
      // Multiple refresh() calls during build coalesce into one increment
      expect(container.read(appRefreshProvider), 1);

      await tester.pump();
      // Still 1 — no duplicate increments from coalescing
      expect(container.read(appRefreshProvider), 1);
    });
  });
}

class _RefreshDuringBuild extends ConsumerWidget {
  const _RefreshDuringBuild({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(appRefreshProvider.notifier).refresh();
    return const SizedBox.shrink();
  }
}

class _MultiRefreshDuringBuild extends ConsumerWidget {
  const _MultiRefreshDuringBuild({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(appRefreshProvider.notifier).refresh();
    ref.read(appRefreshProvider.notifier).refresh();
    ref.read(appRefreshProvider.notifier).refresh();
    return const SizedBox.shrink();
  }
}
