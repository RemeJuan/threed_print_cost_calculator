import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

import 'helpers/integration_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('premium user filters seeded history records by search query', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium(
      seed: (harness) async {
        await harness.seedHistory([
          _historyEntry(
            name: 'History Alpha',
            printer: 'Printer A',
            material: 'PLA Black',
            date: DateTime.parse('2024-01-03T12:00:00.000Z'),
          ),
          _historyEntry(
            name: 'History Beta',
            printer: 'Printer B',
            material: 'PETG White',
            date: DateTime.parse('2024-01-02T12:00:00.000Z'),
          ),
          _historyEntry(
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
    await _tapByKey(tester, 'nav.history.button');

    await _expectHistoryVisibleAnywhere(tester, 'History Alpha');
    await _expectHistoryVisibleAnywhere(tester, 'History Beta');
    await _expectHistoryVisibleAnywhere(tester, 'History Gamma');
    await _scrollHistoryToTop(tester);

    await _enterTextByKey(tester, 'history.search.input', 'Printer B');
    await _settleDebounce(tester);

    expect(find.byKey(_historyCardKey('History Alpha')), findsNothing);
    expect(find.byKey(_historyCardKey('History Beta')), findsOneWidget);
    expect(find.byKey(_historyCardKey('History Gamma')), findsNothing);
    expect(
      _textFromKey(tester, 'history.item.History Beta.summary'),
      contains('PETG White'),
    );

    await _tapByKey(tester, 'history.search.clear.button');
    await _settleDebounce(tester);

    await _enterTextByKey(tester, 'history.search.input', 'History Gamma');
    await _settleDebounce(tester);

    expect(find.byKey(_historyCardKey('History Alpha')), findsNothing);
    expect(find.byKey(_historyCardKey('History Beta')), findsNothing);
    expect(find.byKey(_historyCardKey('History Gamma')), findsOneWidget);
    expect(
      _textFromKey(tester, 'history.item.History Gamma.summary'),
      contains('ABS Red'),
    );
  });
}

HistoryModel _historyEntry({
  required String name,
  required String printer,
  required String material,
  required DateTime date,
}) {
  return HistoryModel(
    name: name,
    totalCost: 20.5,
    riskCost: 1.0,
    filamentCost: 15.0,
    electricityCost: 2.5,
    labourCost: 2.0,
    date: date,
    printer: printer,
    material: material,
    weight: 100,
    materialUsages: [
      {
        'materialId': '${material.toLowerCase().replaceAll(' ', '-')}-id',
        'materialName': material,
        'costPerKg': 150.0,
        'weightGrams': 100,
      },
    ],
    timeHours: '01:30',
  );
}

ValueKey<String> _historyCardKey(String name) {
  return ValueKey<String>('history.item.$name.card');
}

Future<void> _tapByKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enterTextByKey(
  WidgetTester tester,
  String key,
  String value,
) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, value);
  await tester.pump();
}

Future<void> _settleDebounce(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

String _textFromKey(WidgetTester tester, String key) {
  final widget = tester.widget<Text>(find.byKey(ValueKey<String>(key)));
  return widget.data ?? '';
}

Future<void> _expectHistoryVisibleAnywhere(
  WidgetTester tester,
  String name,
) async {
  final finder = find.byKey(_historyCardKey(name));
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  expect(finder, findsOneWidget);
}

Future<void> _scrollHistoryToTop(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;

  for (var i = 0; i < 5; i++) {
    if (find
        .byKey(const ValueKey<String>('history.search.input'))
        .evaluate()
        .isNotEmpty) {
      break;
    }

    await tester.fling(scrollable, const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
  }

  expect(
    find.byKey(const ValueKey<String>('history.search.input')),
    findsOneWidget,
  );
}
