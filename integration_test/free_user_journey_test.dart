import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const electricityCostPerKwh = 3.00;
  const wattage = 120;
  const materialCostPerKg = 200.00;
  const materialWeightGrams = 1000;
  const printWeightGrams = 150;
  const durationHours = 2;
  const durationMinutes = 30;

  setUpAll(() async {
    AppAnalytics.service = _NoopAnalyticsService();
  });

  testWidgets('calculates the deterministic free-user journey end to end', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await databaseFactoryMemory.openDatabase(
      'integration_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    addTearDown(() => db.close());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          purchasesGatewayProvider.overrideWithValue(
            _FakePurchasesGateway(
              const PremiumState(
                isPremium: false,
                isLoading: false,
                userId: 'integration-free',
              ),
            ),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await _tapByKey(tester, 'nav.settings.button');

    await _enterTextByKey(
      tester,
      'settings.electricityCost.input',
      electricityCostPerKwh.toStringAsFixed(2),
    );
    await _enterTextByKey(
      tester,
      'settings.generalWattage.input',
      wattage.toString(),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await _tapByKey(tester, 'nav.calculator.button');
    await tester.pumpAndSettle();
    await _tapByKey(tester, 'nav.settings.button');
    await tester.pumpAndSettle();

    expect(
      _focusSafeFieldText(tester, 'settings.electricityCost.input'),
      anyOf('3.0', '3.00'),
    );

    await _tapByKey(tester, 'nav.calculator.button');
    await tester.pumpAndSettle();

    await _enterTextByKey(
      tester,
      'calculator.spoolWeight.input',
      materialWeightGrams.toString(),
    );
    await _enterTextByKey(
      tester,
      'calculator.spoolCost.input',
      materialCostPerKg.toStringAsFixed(2),
    );

    await _enterTextByKey(
      tester,
      'calculator.printWeight.input',
      printWeightGrams.toString(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await _tapByKey(tester, 'calculator.duration.button');
    await tester.pumpAndSettle();
    await _enterTextByKey(
      tester,
      'calculator.duration.hours.input',
      durationHours.toString(),
    );
    await _enterTextByKey(
      tester,
      'calculator.duration.minutes.input',
      durationMinutes.toString(),
    );
    await _tapByKey(tester, 'calculator.duration.save.button');
    await tester.pumpAndSettle();

    final expectedElectricityCost =
        (wattage / 1000) *
        (durationHours + durationMinutes / 60) *
        electricityCostPerKwh;
    final expectedFilamentCost = (printWeightGrams / 1000) * materialCostPerKg;
    final expectedTotalCost = expectedElectricityCost + expectedFilamentCost;

    expect(
      _numberFromKey(tester, 'calculator.result.electricityCost'),
      closeTo(expectedElectricityCost, 0.001),
    );
    expect(
      _numberFromKey(tester, 'calculator.result.filamentCost'),
      closeTo(expectedFilamentCost, 0.001),
    );
    expect(
      _numberFromKey(tester, 'calculator.result.totalCost'),
      closeTo(expectedTotalCost, 0.001),
    );
  });
}

class _NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {}
}

class _FakePurchasesGateway implements PurchasesGateway {
  _FakePurchasesGateway(this._premiumState);

  final PremiumState _premiumState;

  @override
  void dispose() {}

  @override
  Future<PremiumState> fetchPremiumState() async => _premiumState;

  @override
  Stream<PremiumState> watchPremiumState() => const Stream.empty();
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

String _focusSafeFieldText(WidgetTester tester, String key) {
  final widget = tester.widget<FocusSafeTextField>(
    find.byKey(ValueKey<String>(key)),
  );
  return widget.controller.text;
}

double _numberFromKey(WidgetTester tester, String key) {
  final widget = tester.widget<Text>(find.byKey(ValueKey<String>(key)));
  return double.parse((widget.data ?? '').replaceAll(RegExp(r'[^0-9.\-]'), ''));
}
