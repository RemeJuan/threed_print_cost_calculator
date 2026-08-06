import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/startup/post_first_frame_startup.dart';

void main() {
  testWidgets('runs only after first frame', (tester) async {
    final calls = <String>[];

    schedulePostFirstFrameStartupTasks(
      enableAnalyticsCollection: () async {
        calls.add('analytics');
      },
      activateAppCheck: () async {
        calls.add('app_check');
      },
      reportError: (_) {},
    );

    expect(calls, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(calls, ['analytics', 'app_check']);
  });

  testWidgets('reports task failure and continues', (tester) async {
    final calls = <String>[];
    final reported = <FlutterErrorDetails>[];

    schedulePostFirstFrameStartupTasks(
      enableAnalyticsCollection: () async {
        calls.add('analytics');
        throw StateError('analytics failed');
      },
      activateAppCheck: () async {
        calls.add('app_check');
      },
      reportError: reported.add,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(calls, ['analytics', 'app_check']);
    expect(reported, hasLength(1));
    expect(reported.single.library, 'postFirstFrameStartupTasks');
    expect(
      reported.single.context.toString(),
      'Firebase Analytics collection enablement',
    );
    expect(reported.single.exception, isA<StateError>());
  });
}
