import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';

extension IntegrationTestUiWidgetTesterX on WidgetTester {
  Future<void> _settleTransientOverlays() async {
    await pump();
    await pump(const Duration(milliseconds: 50));
    await pumpAndSettle(const Duration(milliseconds: 100));
  }

  Finder? _firstVisibleKeyFinder(String key) {
    final rawFinder = find.byKey(ValueKey<String>(key)).hitTestable();
    final candidates = rawFinder.evaluate();
    if (candidates.isEmpty) {
      return null;
    }

    return rawFinder;
  }

  Future<void> _tapVisible(
    String key, {
    Duration timeout = const Duration(seconds: 5),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final deadline = DateTime.now().add(timeout);
    TestFailure? lastFailure;

    while (DateTime.now().isBefore(deadline)) {
      final finder = _firstVisibleKeyFinder(key);
      if (finder == null) {
        await _settleTransientOverlays();
        await pump(step);
        continue;
      }

      try {
        await ensureVisible(finder);
        await pump();
        final tapFinder = _firstVisibleKeyFinder(key);
        if (tapFinder == null) {
          await _settleTransientOverlays();
          await pump(step);
          continue;
        }

        await tap(tapFinder);
        await _settleTransientOverlays();
        return;
      } catch (error) {
        lastFailure = error is TestFailure
            ? error
            : TestFailure(error.toString());
        await _settleTransientOverlays();
        await pump(step);
      }
    }

    fail(
      'Unable to tap visible widget with key "$key" after ${timeout.inSeconds}s${lastFailure == null ? '.' : ': ${lastFailure.message}'}',
    );
  }

  Future<void> tapByKey(String key) async {
    await _tapVisible(key);
  }

  Future<void> enterTextByKey(String key, String value) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    TestFailure? lastFailure;

    while (DateTime.now().isBefore(deadline)) {
      final finder = _firstVisibleKeyFinder(key);
      if (finder == null) {
        await _settleTransientOverlays();
        await pump(const Duration(milliseconds: 100));
        continue;
      }

      try {
        await ensureVisible(finder);
        await pump();
        await tap(finder);
        await _settleTransientOverlays();
        await enterText(finder, value);
        await _settleTransientOverlays();
        return;
      } catch (error) {
        lastFailure = error is TestFailure
            ? error
            : TestFailure(error.toString());
        await _settleTransientOverlays();
        await pump(const Duration(milliseconds: 100));
      }
    }

    fail(
      'Unable to enter text for visible widget with key "$key"${lastFailure == null ? '.' : ': ${lastFailure.message}'}',
    );
  }

  Future<void> selectDropdownValueByKey(
    String dropdownKey,
    String optionKey,
  ) async {
    await _tapVisible(dropdownKey);
    await _tapVisible(optionKey);
  }

  Future<void> scrollUntilKeyVisible(String key, {double delta = 150}) async {
    await scrollUntilKeyVisibleInScrollable(key, delta: delta);
  }

  Future<void> scrollUntilKeyVisibleInScrollable(
    String key, {
    Finder? scrollable,
    double delta = 150,
  }) async {
    final finder = find.byKey(ValueKey<String>(key));
    const timeout = Duration(seconds: 5);
    final deadline = DateTime.now().add(timeout);
    TestFailure? lastFailure;

    while (DateTime.now().isBefore(deadline)) {
      final targetHitTestable = finder.hitTestable();
      if (targetHitTestable.evaluate().isNotEmpty) {
        await _settleTransientOverlays();
        return;
      }

      final scrollableFinders = scrollable == null
          ? <Finder>[
              ...find
                  .ancestor(of: finder, matching: find.byType(Scrollable))
                  .evaluate()
                  .map(
                    (element) => find.byWidget(element.widget).hitTestable(),
                  ),
              ...find
                  .byType(Scrollable)
                  .evaluate()
                  .map(
                    (element) => find.byWidget(element.widget).hitTestable(),
                  ),
            ]
          : <Finder>[scrollable.hitTestable()];

      if (scrollableFinders.isEmpty) {
        await _settleTransientOverlays();
        await pump(const Duration(milliseconds: 100));
        continue;
      }

      for (final candidate in scrollableFinders) {
        try {
          await scrollUntilVisible(finder, delta, scrollable: candidate);
          await _settleTransientOverlays();
          return;
        } catch (error) {
          lastFailure = error is TestFailure
              ? error
              : TestFailure(error.toString());
        }
      }

      await _settleTransientOverlays();
      await pump(const Duration(milliseconds: 100));
    }

    fail(
      'Unable to scroll widget with key "$key" into view after ${timeout.inSeconds}s${lastFailure == null ? '.' : ': ${lastFailure.message}'}',
    );
  }

  Future<void> settleDebounce() async {
    await pump(const Duration(milliseconds: 500));
    await _settleTransientOverlays();
  }

  Future<void> expectFieldTextEventually(
    String key,
    Matcher matcher, {
    Duration timeout = const Duration(seconds: 5),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      final text = focusSafeFieldText(key);
      if (matcher.matches(text, <dynamic, dynamic>{})) {
        return;
      }

      await pump(step);
    }

    expect(focusSafeFieldText(key), matcher);
  }

  String focusSafeFieldText(String key) {
    final widget = this.widget<FocusSafeTextField>(
      find.byKey(ValueKey<String>(key)),
    );
    return widget.controller.text;
  }

  String textFromKey(String key) {
    final widget = this.widget<Text>(find.byKey(ValueKey<String>(key)));
    return widget.data ?? '';
  }

  double numberFromTextKey(String key) {
    final rawText = textFromKey(key);
    final cleaned = rawText.replaceAll(RegExp(r'[^0-9.\-]'), '');

    if (cleaned.isEmpty ||
        cleaned == '-' ||
        cleaned == '.' ||
        cleaned == '-.') {
      throw FormatException(
        'Expected numeric text for key "$key", found "$rawText".',
      );
    }

    return double.parse(cleaned);
  }
}

String historyItemKey(String historyId, String suffix) {
  return 'history.item.$historyId.$suffix';
}

ValueKey<String> historyCardKey(String historyId) {
  return ValueKey<String>(historyItemKey(historyId, 'card'));
}

Future<void> expectHistoryVisibleAnywhere(
  WidgetTester tester,
  String historyId,
) async {
  final finder = find.byKey(historyCardKey(historyId));
  final historyScrollable = find
      .ancestor(
        of: find.byKey(const ValueKey<String>('history.list')),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(finder, 200, scrollable: historyScrollable);
  expect(finder, findsOneWidget);
}

Future<void> waitForKeyEventually(
  WidgetTester tester,
  String key, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  final finder = find.byKey(ValueKey<String>(key));

  while (DateTime.now().isBefore(deadline)) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }

  fail('Timed out waiting for key "$key".');
}

Future<void> scrollHistoryToTop(WidgetTester tester) async {
  final scrollable = find
      .ancestor(
        of: find.byKey(const ValueKey<String>('history.list')),
        matching: find.byType(Scrollable),
      )
      .first;

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

void expectCalculatorResultValues(
  WidgetTester tester, {
  double? electricityCost,
  double? filamentCost,
  double? labourCost,
  double? riskCost,
  double? totalCost,
}) {
  void expectCost(String key, double? expectedValue) {
    if (expectedValue == null) {
      return;
    }

    expect(tester.numberFromTextKey(key), closeTo(expectedValue, 0.01));
  }

  expectCost('calculator.result.electricityCost', electricityCost);
  expectCost('calculator.result.filamentCost', filamentCost);
  expectCost('calculator.result.labourCost', labourCost);
  expectCost('calculator.result.riskCost', riskCost);
  expectCost('calculator.result.totalCost', totalCost);
}

void expectHistoryItemCostValues(
  WidgetTester tester,
  String name, {
  double? electricityCost,
  double? filamentCost,
  double? labourCost,
  double? riskCost,
  double? totalCost,
}) {
  void expectCost(String suffix, double? expectedValue) {
    if (expectedValue == null) {
      return;
    }

    expect(
      tester.numberFromTextKey(historyItemKey(name, suffix)),
      closeTo(expectedValue, 0.01),
    );
  }

  expectCost('electricityCost', electricityCost);
  expectCost('filamentCost', filamentCost);
  expectCost('labourCost', labourCost);
  expectCost('riskCost', riskCost);
  expectCost('totalCost', totalCost);
}
