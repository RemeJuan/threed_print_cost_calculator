import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

// Local-only integration smoke test.
// Kept to exercise history search/filter wiring outside the Patrol gate.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('premium user filters seeded history records by search query', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium(
      seed: (harness) async {
        await harness.seedHistory([
          IntegrationFixtures.buildHistoryEntry(
            name: 'History Alpha',
            printer: 'Printer A',
            material: 'PLA Black',
            date: DateTime.parse('2024-01-03T12:00:00.000Z'),
          ),
          IntegrationFixtures.buildHistoryEntry(
            name: 'History Beta',
            printer: 'Printer B',
            material: 'PETG White',
            date: DateTime.parse('2024-01-02T12:00:00.000Z'),
          ),
          IntegrationFixtures.buildHistoryEntry(
            name: 'History Gamma',
            printer: 'Printer C',
            material: 'ABS Red',
            date: DateTime.parse('2024-01-01T12:00:00.000Z'),
          ),
        ]);
      },
    );
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await tester.tapByKey('nav.history.button');
    await tester.pumpAndSettle();

    await tester.enterTextByKey('history.search.input', 'Printer B');
    await tester.settleDebounce();
    await tester.pumpAndSettle();

    await scrollHistoryToTop(tester);

    expect(
      tester.textFromKey('history.item.History Beta.summary'),
      contains('PETG White'),
    );
    expect(
      find.byKey(const ValueKey<String>('history.item.History Beta.summary')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('history.item.History Alpha.summary')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('history.item.History Gamma.summary')),
      findsNothing,
    );

    await tester.tapByKey('history.search.clear.button');
    await tester.settleDebounce();
    await tester.pumpAndSettle();

    await tester.enterTextByKey('history.search.input', 'History Gamma');
    await tester.settleDebounce();
    await tester.pumpAndSettle();

    await scrollHistoryToTop(tester);

    expect(
      tester.textFromKey('history.item.History Gamma.summary'),
      contains('ABS Red'),
    );
    expect(
      find.byKey(const ValueKey<String>('history.item.History Gamma.summary')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('history.item.History Alpha.summary')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('history.item.History Beta.summary')),
      findsNothing,
    );
  });
}
