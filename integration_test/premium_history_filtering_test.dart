import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

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

    await expectHistoryVisibleAnywhere(tester, 'History Alpha');
    await expectHistoryVisibleAnywhere(tester, 'History Beta');
    await expectHistoryVisibleAnywhere(tester, 'History Gamma');
    await scrollHistoryToTop(tester);

    await tester.enterTextByKey('history.search.input', 'Printer B');
    await tester.settleDebounce();

    expect(find.byKey(historyCardKey('History Alpha')), findsNothing);
    expect(find.byKey(historyCardKey('History Beta')), findsOneWidget);
    expect(find.byKey(historyCardKey('History Gamma')), findsNothing);
    expect(
      tester.textFromKey('history.item.History Beta.summary'),
      contains('PETG White'),
    );

    await tester.tapByKey('history.search.clear.button');
    await tester.settleDebounce();

    await tester.enterTextByKey('history.search.input', 'History Gamma');
    await tester.settleDebounce();

    expect(find.byKey(historyCardKey('History Alpha')), findsNothing);
    expect(find.byKey(historyCardKey('History Beta')), findsNothing);
    expect(find.byKey(historyCardKey('History Gamma')), findsOneWidget);
    expect(
      tester.textFromKey('history.item.History Gamma.summary'),
      contains('ABS Red'),
    );
  });
}
