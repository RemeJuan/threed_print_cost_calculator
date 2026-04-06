import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';

ValueKey<String> patrolKey(String key) => ValueKey<String>(key);

extension PatrolIntegrationTesterUiX on PatrolIntegrationTester {
  Future<void> tapByKey(String key) {
    return this(patrolKey(key)).tap();
  }

  Future<void> enterTextByKey(String key, String value) {
    return this(patrolKey(key)).enterText(value);
  }

  Future<void> selectDropdownValueByKey(
    String dropdownKey,
    String optionKey,
  ) async {
    await tapByKey(dropdownKey);

    final optionFinder = find.byKey(patrolKey(optionKey)).last;
    await tester.ensureVisible(optionFinder);
    await tester.tap(optionFinder);
    await pumpAndSettle();
  }

  Future<void> settleDebounce() async {
    await pump(const Duration(milliseconds: 500));
    await pumpAndSettle();
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
    final widget = tester.widget<FocusSafeTextField>(
      find.byKey(patrolKey(key)),
    );
    final controller = widget.controller;
    return controller.text;
  }

  String textFromKey(String key) {
    final widget = tester.widget<Text>(find.byKey(patrolKey(key)));
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

String historyItemKey(String name, String suffix) {
  return 'history.item.$name.$suffix';
}

ValueKey<String> historyCardKey(String name) {
  return ValueKey<String>(historyItemKey(name, 'card'));
}

Future<void> expectHistoryVisibleAnywhere(
  PatrolIntegrationTester $,
  String name,
) async {
  final finder = find.byKey(historyCardKey(name));
  await $.tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  expect(finder, findsOneWidget);
}

void expectCalculatorResultValues(
  PatrolIntegrationTester $, {
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

    expect($.numberFromTextKey(key), closeTo(expectedValue, 0.01));
  }

  expectCost('calculator.result.electricityCost', electricityCost);
  expectCost('calculator.result.filamentCost', filamentCost);
  expectCost('calculator.result.labourCost', labourCost);
  expectCost('calculator.result.riskCost', riskCost);
  expectCost('calculator.result.totalCost', totalCost);
}

void expectHistoryItemCostValues(
  PatrolIntegrationTester $,
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
      $.numberFromTextKey(historyItemKey(name, suffix)),
      closeTo(expectedValue, 0.01),
    );
  }

  expectCost('electricityCost', electricityCost);
  expectCost('filamentCost', filamentCost);
  expectCost('labourCost', labourCost);
  expectCost('riskCost', riskCost);
  expectCost('totalCost', totalCost);
}
