import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/purchases/cancel_feedback_sheet.dart';

import '../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(setupTest);

  testWidgets('dismiss calls onDismiss once', (tester) async {
    var dismissCount = 0;
    var submitCount = 0;

    await tester.pumpApp(
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showCancelFeedbackSheet(
              context,
              onDismiss: () async {
                dismissCount++;
              },
              onSubmitted: (_) async {
                submitCount++;
              },
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(dismissCount, 1);
    expect(submitCount, 0);
  });

  testWidgets('submit sends selected reason and skips dismiss', (tester) async {
    CancelFeedbackReason? submittedReason;
    var dismissCount = 0;

    await tester.pumpApp(
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showCancelFeedbackSheet(
              context,
              onDismiss: () async {
                dismissCount++;
              },
              onSubmitted: (reason) async {
                submittedReason = reason;
              },
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Too expensive'));
    await tester.pump();
    await tester.tap(find.text('Send feedback'));
    await tester.pumpAndSettle();

    expect(submittedReason, CancelFeedbackReason.tooExpensive);
    expect(dismissCount, 0);
  });

  testWidgets('submit disabled until reason selected', (tester) async {
    await tester.pumpApp(const CancelFeedbackSheet(onSubmitted: _noopSubmit));

    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Close'))
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Send feedback'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Too expensive'));
    await tester.pump();

    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Send feedback'),
          )
          .onPressed,
      isNotNull,
    );
  });
}

Future<void> _noopSubmit(CancelFeedbackReason reason) async {}
