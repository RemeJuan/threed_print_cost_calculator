import 'package:bot_toast/bot_toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/services/calculator_save_coordinator.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/database/services/material_stock_service.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class _RecordingHistoryRepository extends HistoryRepository {
  _RecordingHistoryRepository(
    super.ref, {
    this.shouldThrow = false,
    this.count = 0,
    this.events,
  });

  final bool shouldThrow;
  int count;
  final List<String>? events;
  final List<HistoryModel> saved = [];

  @override
  Future<int> countHistory() async {
    events?.add('count:$count');
    return count;
  }

  @override
  Future<Object?> saveHistory(HistoryModel model) async {
    events?.add('save');
    if (shouldThrow) {
      throw Exception('save failed');
    }

    saved.add(model);
    return 1;
  }
}

class _RecordingMaterialStockService extends MaterialStockService {
  _RecordingMaterialStockService(
    super.ref, {
    this.shouldThrow = false,
    this.events,
  });

  final bool shouldThrow;
  final List<String>? events;
  final List<HistoryModel> deducted = [];

  @override
  Future<void> deductForSavedHistory(HistoryModel history) async {
    events?.add('deduct');
    if (shouldThrow) {
      throw Exception('deduction failed');
    }

    deducted.add(history);
  }
}

class _RecordingPaywallPresenter implements PaywallPresenter {
  final List<String> events;
  _RecordingPaywallPresenter(this.events, {this.onPresent});
  final void Function()? onPresent;

  String? purchaseSource;
  String? triggerFeature;

  @override
  Future<void> present(
    String offeringId, {
    required String triggerFeature,
    required String purchaseSource,
    String defaultEntryPoint = 'manual',
    String source = 'unknown',
    int? launchCount,
  }) async {
    events.add('paywall');
    onPresent?.call();
    this.purchaseSource = purchaseSource;
    this.triggerFeature = triggerFeature;
  }
}

class _HistoryQuotaPolicy extends DefaultPremiumAccessPolicy {
  _HistoryQuotaPolicy() : super(isPremium: false);

  final List<int> checkedCounts = [];
  @override
  QuotaAccess canSaveHistoryItem(int currentCount) {
    checkedCounts.add(currentCount);
    return QuotaAccess(
      allowed: currentCount == 0,
      currentCount: currentCount,
      limit: 0,
      denyReason: AccessDenyReason.quotaExceeded,
    );
  }
}

class _RecordingLogSink extends AppLogSink {
  final List<AppLogEvent> events = [];

  @override
  void log(AppLogEvent event) {
    events.add(event);
  }
}

HistoryModel _buildHistoryModel() {
  return HistoryModel(
    name: 'Saved print',
    totalCost: 10,
    riskCost: 1,
    filamentCost: 5,
    electricityCost: 2,
    labourCost: 2,
    date: DateTime.parse('2024-01-01T00:00:00.000Z'),
    printer: 'Printer',
    material: 'PLA',
    weight: 100,
    materialUsages: const [
      {
        'materialId': 'mat-1',
        'materialName': 'PLA',
        'costPerKg': 20,
        'weightGrams': 100,
      },
    ],
    timeHours: '01:00',
  );
}

Future<void> _pumpToastApp(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  test('should calculate electricityCost', () async {
    //arrange
    const watts = 200;
    const minutes = 60;
    const hours = 1;
    const cost = 1.0;
    //act
    final result = container
        .read(calculatorHelpersProvider)
        .electricityCost(watts, hours, minutes, cost);
    //assert
    expect(result, equals(0.4));
  });

  test('should calculate filament cost', () async {
    //arrange
    const itemWeight = 10;
    const spoolWeight = 1000;
    const cost = 200;
    //act
    final result = container
        .read(calculatorHelpersProvider)
        .filamentCost(itemWeight, spoolWeight, cost);
    //assert
    expect(result, equals(2.0));
  });

  test('single material through multi-material API matches old behavior', () {
    const usage = MaterialUsageInput(
      materialId: 'pla-black',
      materialName: 'PLA Black',
      costPerKg: 200,
      weightGrams: 10,
    );

    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost([usage]);

    expect(result, equals(2.0));
  });

  test('multi-material sums correctly with different cost per kg', () {
    const usages = [
      MaterialUsageInput(
        materialId: 'pla-black',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 120,
      ),
      MaterialUsageInput(
        materialId: 'pla-white',
        materialName: 'PLA White',
        costPerKg: 250,
        weightGrams: 35,
      ),
    ];

    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost(usages);

    expect(result, equals(32.75));
  });

  test('risk formula remains unchanged with multi-material filament total', () {
    final filament = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost([
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'M1',
            costPerKg: 210,
            weightGrams: 100,
          ),
        ]);
    final electricity = container
        .read(calculatorHelpersProvider)
        .electricityCost(200, 1, 0, 1);
    final labour = 3;
    final wearAndTear = 1;
    const riskPercent = 10;

    final baseTotal = filament + electricity + labour + wearAndTear;
    final risk = num.parse((riskPercent / 100 * baseTotal).toStringAsFixed(2));

    expect(filament, equals(21.0));
    expect(baseTotal, equals(25.2));
    expect(risk, equals(2.52));
  });

  test('multiMaterialFilamentCost returns 0 for empty list', () {
    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost([]);
    expect(result, equals(0.0));
  });

  test(
    'multiMaterialFilamentCost rounds per-item costs to cents (precision boundary)',
    () {
      // Two usages that each produce raw per-item cost 0.005. With
      // per-item rounding to cents, each becomes 0.01, so total should be 0.02.
      const u1 = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'M1',
        costPerKg: 5, // (1g * 5) / 1000 = 0.005
        weightGrams: 1,
      );
      const u2 = MaterialUsageInput(
        materialId: 'm2',
        materialName: 'M2',
        costPerKg: 5, // same as above
        weightGrams: 1,
      );

      final result = container
          .read(calculatorHelpersProvider)
          .multiMaterialFilamentCost([u1, u2]);

      // Per-item rounding should produce exactly 0.02
      expect(result, equals(0.02));
    },
  );

  testWidgets('savePrint skips stock deduction when history save fails', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    late _RecordingHistoryRepository historyRepository;
    _RecordingMaterialStockService? stockService;
    final overrideContainer = ProviderContainer(
      overrides: [
        historyRepositoryProvider.overrideWith((ref) {
          historyRepository = _RecordingHistoryRepository(
            ref,
            shouldThrow: true,
          );
          return historyRepository;
        }),
        materialStockServiceProvider.overrideWith((ref) {
          final service = _RecordingMaterialStockService(ref);
          stockService = service;
          return service;
        }),
        sharedPreferencesProvider.overrideWithValue(prefs),
        isPremiumProvider.overrideWithValue(true),
      ],
    );
    addTearDown(overrideContainer.dispose);

    await _pumpToastApp(tester, overrideContainer);
    await overrideContainer
        .read(calculatorSaveCoordinatorProvider)
        .savePrint(
          _buildHistoryModel(),
          errorMessage: lookupAppLocalizations(
            const Locale('en'),
          ).savePrintErrorMessage,
          successMessage: lookupAppLocalizations(
            const Locale('en'),
          ).savePrintSuccessMessage,
        );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));

    expect(historyRepository.saved, isEmpty);
    expect(stockService, isNull);
  });

  testWidgets(
    'savePrint logs warning and keeps success path when deduction fails',
    (tester) async {
      final logSink = _RecordingLogSink();
      late _RecordingHistoryRepository historyRepository;
      late _RecordingMaterialStockService stockService;
      final prefs = await SharedPreferences.getInstance();
      final overrideContainer = ProviderContainer(
        overrides: [
          historyRepositoryProvider.overrideWith((ref) {
            historyRepository = _RecordingHistoryRepository(ref);
            return historyRepository;
          }),
          materialStockServiceProvider.overrideWith((ref) {
            stockService = _RecordingMaterialStockService(
              ref,
              shouldThrow: true,
            );
            return stockService;
          }),
          appLogSinkProvider.overrideWithValue(logSink),
          appLoggerConfigProvider.overrideWithValue(
            const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
          isPremiumProvider.overrideWithValue(true),
        ],
      );
      addTearDown(overrideContainer.dispose);

      await _pumpToastApp(tester, overrideContainer);

      final history = _buildHistoryModel();
      await overrideContainer
          .read(calculatorSaveCoordinatorProvider)
          .savePrint(
            history,
            errorMessage: lookupAppLocalizations(
              const Locale('en'),
            ).savePrintErrorMessage,
            successMessage: lookupAppLocalizations(
              const Locale('en'),
            ).savePrintSuccessMessage,
          );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      expect(historyRepository.saved, [history]);
      expect(stockService.deducted, isEmpty);
      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).savePrintSuccessMessage,
        ),
        findsOneWidget,
      );
      expect(
        logSink.events.any(
          (event) =>
              event.level == AppLogLevel.warn &&
              event.message ==
                  'History saved but material stock deduction failed',
        ),
        isTrue,
      );
    },
  );

  testWidgets('quota denial presents paywall, recounts, then saves in order', (
    tester,
  ) async {
    final events = <String>[];
    late _RecordingHistoryRepository historyRepository;
    late _HistoryQuotaPolicy policy;
    final paywall = _RecordingPaywallPresenter(
      events,
      onPresent: () {
        historyRepository.count = 0;
      },
    );
    final prefs = await SharedPreferences.getInstance();
    final overrideContainer = ProviderContainer(
      overrides: [
        historyRepositoryProvider.overrideWith((ref) {
          historyRepository = _RecordingHistoryRepository(
            ref,
            count: 1,
            events: events,
          );
          return historyRepository;
        }),
        premiumAccessPolicyProvider.overrideWith((ref) {
          policy = _HistoryQuotaPolicy();
          return policy;
        }),
        paywallPresenterProvider.overrideWithValue(paywall),
        materialStockServiceProvider.overrideWith(
          (ref) => _RecordingMaterialStockService(ref, events: events),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
        isPremiumProvider.overrideWithValue(false),
      ],
    );
    addTearDown(overrideContainer.dispose);
    await _pumpToastApp(tester, overrideContainer);

    await overrideContainer
        .read(calculatorSaveCoordinatorProvider)
        .savePrint(
          _buildHistoryModel(),
          errorMessage: lookupAppLocalizations(
            const Locale('en'),
          ).savePrintErrorMessage,
          successMessage: lookupAppLocalizations(
            const Locale('en'),
          ).savePrintSuccessMessage,
        );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(paywall.purchaseSource, 'save_history');
    expect(paywall.triggerFeature, PremiumFeature.saveToHistory.name);
    expect(policy.checkedCounts, [1, 0]);
    expect(events, ['count:1', 'paywall', 'count:0', 'save', 'deduct']);
    expect(historyRepository.saved, hasLength(1));
    expect(
      find.text(
        lookupAppLocalizations(const Locale('en')).savePrintSuccessMessage,
      ),
      findsOneWidget,
    );
  });

  testWidgets('quota remains exceeded after paywall and skips persistence', (
    tester,
  ) async {
    final events = <String>[];
    late _RecordingHistoryRepository historyRepository;
    late _HistoryQuotaPolicy policy;
    final paywall = _RecordingPaywallPresenter(events);
    final prefs = await SharedPreferences.getInstance();
    final overrideContainer = ProviderContainer(
      overrides: [
        historyRepositoryProvider.overrideWith((ref) {
          historyRepository = _RecordingHistoryRepository(
            ref,
            count: 1,
            events: events,
          );
          return historyRepository;
        }),
        premiumAccessPolicyProvider.overrideWith((ref) {
          policy = _HistoryQuotaPolicy();
          return policy;
        }),
        paywallPresenterProvider.overrideWithValue(paywall),
        materialStockServiceProvider.overrideWith(
          (ref) => _RecordingMaterialStockService(ref, events: events),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
        isPremiumProvider.overrideWithValue(false),
      ],
    );
    addTearDown(overrideContainer.dispose);
    await _pumpToastApp(tester, overrideContainer);

    await overrideContainer
        .read(calculatorSaveCoordinatorProvider)
        .savePrint(
          _buildHistoryModel(),
          errorMessage: lookupAppLocalizations(
            const Locale('en'),
          ).savePrintErrorMessage,
          successMessage: lookupAppLocalizations(
            const Locale('en'),
          ).savePrintSuccessMessage,
        );

    expect(policy.checkedCounts, [1, 1]);
    expect(events, ['count:1', 'paywall', 'count:1']);
    expect(historyRepository.saved, isEmpty);
    expect(
      find.text(
        lookupAppLocalizations(const Locale('en')).savePrintSuccessMessage,
      ),
      findsNothing,
    );
    expect(
      find.text(
        lookupAppLocalizations(const Locale('en')).savePrintErrorMessage,
      ),
      findsNothing,
    );
  });
}
