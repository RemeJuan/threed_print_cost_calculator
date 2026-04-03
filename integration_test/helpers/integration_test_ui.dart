import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';

extension IntegrationTestUiWidgetTesterX on WidgetTester {
  Future<void> tapByKey(String key) async {
    final finder = find.byKey(ValueKey<String>(key));
    await ensureVisible(finder);
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> enterTextByKey(String key, String value) async {
    final finder = find.byKey(ValueKey<String>(key));
    await ensureVisible(finder);
    await tap(finder);
    await pumpAndSettle();
    await enterText(finder, value);
    await pump();
  }

  Future<void> selectDropdownValueByKey(
    String dropdownKey,
    String optionKey,
  ) async {
    await tapByKey(dropdownKey);
    final optionFinder = find.byKey(ValueKey<String>(optionKey)).last;
    await ensureVisible(optionFinder);
    await tap(optionFinder);
    await pumpAndSettle();
  }

  Future<void> scrollUntilKeyVisible(String key, {double delta = 150}) async {
    final finder = find.byKey(ValueKey<String>(key));
    await scrollUntilVisible(
      finder,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpAndSettle();
  }

  Future<void> settleDebounce() async {
    await pump(const Duration(milliseconds: 500));
    await pumpAndSettle();
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

String historyItemKey(String name, String suffix) {
  return 'history.item.$name.$suffix';
}

ValueKey<String> historyCardKey(String name) {
  return ValueKey<String>(historyItemKey(name, 'card'));
}

Future<void> expectHistoryVisibleAnywhere(
  WidgetTester tester,
  String name,
) async {
  final finder = find.byKey(historyCardKey(name));
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  expect(finder, findsOneWidget);
}

Future<void> scrollHistoryToTop(WidgetTester tester) async {
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
