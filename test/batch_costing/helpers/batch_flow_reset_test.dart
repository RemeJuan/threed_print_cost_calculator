import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_flow_reset.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';

import '../../helpers/helpers.dart';

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  int resetCount = 0;

  @override
  BatchCostingState build() => BatchCostingState();

  @override
  void reset() {
    resetCount += 1;
    super.reset();
  }
}

class _MountedResetHarness extends ConsumerStatefulWidget {
  const _MountedResetHarness({required this.notifier});

  final _FakeBatchCostingNotifier notifier;

  @override
  ConsumerState<_MountedResetHarness> createState() =>
      _MountedResetHarnessState();
}

class _MountedResetHarnessState extends ConsumerState<_MountedResetHarness> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await resetBatchFlow(context, ref);
      },
      child: const Text('reset'),
    );
  }
}

class _UnmountHarness extends ConsumerStatefulWidget {
  const _UnmountHarness({required this.onReady, required this.onChildReady});

  final void Function(BuildContext context, WidgetRef ref) onReady;
  final void Function(BuildContext context) onChildReady;

  @override
  ConsumerState<_UnmountHarness> createState() => _UnmountHarnessState();
}

class _UnmountHarnessState extends ConsumerState<_UnmountHarness> {
  var showChild = true;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady(context, ref);
    });
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => setState(() => showChild = false),
          child: const Text('hide'),
        ),
        if (showChild)
          _ChildContextCapture(onReady: widget.onChildReady)
        else
          const SizedBox.shrink(),
      ],
    );
  }
}

class _ChildContextCapture extends StatelessWidget {
  const _ChildContextCapture({required this.onReady});

  final void Function(BuildContext context) onReady;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady(context));
    return const SizedBox.shrink();
  }
}

void main() {
  setUpAll(setupTest);

  testWidgets('resetBatchFlow resets provider and navigates when mounted', (
    tester,
  ) async {
    final notifier = _FakeBatchCostingNotifier();
    await tester.pumpApp(_MountedResetHarness(notifier: notifier), [
      batchCostingProvider.overrideWith(() => notifier),
    ]);

    await tester.tap(find.text('reset'));
    await tester.pumpAndSettle();

    expect(notifier.resetCount, 1);
    expect(find.byType(BatchCostingPage), findsOneWidget);
  });

  testWidgets('resetBatchFlow no-ops navigation when unmounted', (
    tester,
  ) async {
    final notifier = _FakeBatchCostingNotifier();
    late BuildContext childContext;
    late WidgetRef parentRef;

    await tester.pumpApp(
      _UnmountHarness(
        onReady: (context, ref) {
          parentRef = ref;
        },
        onChildReady: (context) {
          childContext = context;
        },
      ),
      [batchCostingProvider.overrideWith(() => notifier)],
    );

    await tester.tap(find.text('hide'));
    await tester.pumpAndSettle();
    await resetBatchFlow(childContext, parentRef);

    expect(notifier.resetCount, 1);
    expect(find.byType(BatchCostingPage), findsNothing);
  });
}
