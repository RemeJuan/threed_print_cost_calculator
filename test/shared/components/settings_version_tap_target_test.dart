import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/components/settings_version_tap_target.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/seed_loader.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_service.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

class _NoopAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

class _NoopSeedLoader extends SeedLoader {
  _NoopSeedLoader() : super(bundle: _NoopAssetBundle());

  @override
  Future<SeedDataBundle> load() async {
    throw UnimplementedError();
  }
}

class _FakeTestDataService extends TestDataService {
  _FakeTestDataService(super.ref) : super(loader: _NoopSeedLoader());

  int enablePremiumAndSeedCalls = 0;

  @override
  Future<TestDataOperationResult> enablePremiumAndSeed() async {
    enablePremiumAndSeedCalls += 1;
    return const TestDataOperationResult.success();
  }
}

class _FakeHistoryPagedNotifier extends HistoryPagedNotifier {
  int refreshCalls = 0;

  @override
  HistoryPagedState build() => HistoryPagedState.initial();

  @override
  Future<void> refresh() async {
    refreshCalls += 1;
  }
}

class _FakeAnalytics implements AnalyticsService {
  String? lastName;
  Map<String, Object>? lastParams;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    lastName = name;
    lastParams = params;
  }
}

String _todayCode() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
}

Future<void> _openHiddenTools(WidgetTester tester) async {
  final target = find.byKey(
    const ValueKey<String>('settings.version.tapTarget'),
  );
  await tester.ensureVisible(target);
  for (var i = 0; i < 5; i++) {
    await tester.tap(target);
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pumpAndSettle();
}

Future<void> _revealHiddenToolButton(WidgetTester tester, String key) async {
  await tester.dragUntilVisible(
    find.byKey(ValueKey<String>(key)),
    find.byType(SingleChildScrollView),
    const Offset(0, -200),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeAnalytics fakeAnalytics;

  setUpAll(() async {
    await setupTest();
    PackageInfo.setMockInitialValues(
      appName: 'App',
      packageName: 'pkg',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: 'sig',
    );
  });

  setUp(() {
    fakeAnalytics = _FakeAnalytics();
    AppAnalytics.service = fakeAnalytics;
  });

  testWidgets('shows invalid code message', (tester) async {
    final fakeCalculator = FakeCalculatorNotifier();
    final fakeHistory = _FakeHistoryPagedNotifier();

    final db = await tester.pumpApp(const SettingsVersionTapTarget(), [
      calculatorProvider.overrideWith(() => fakeCalculator),
      historyPagedProvider.overrideWith(() => fakeHistory),
      testDataServiceProvider.overrideWith((ref) => _FakeTestDataService(ref)),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await _openHiddenTools(tester);

    expect(
      find.byKey(const ValueKey<String>('settings.testData.tools.dialog')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.button'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.code'),
      ),
      'wrong',
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.submit.button'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid confirmation code'), findsOneWidget);
  });

  testWidgets('enabling premium refreshes app state', (tester) async {
    final fakeCalculator = FakeCalculatorNotifier();
    final fakeHistory = _FakeHistoryPagedNotifier();
    late _FakeTestDataService fakeTestDataService;

    final db = await tester.pumpApp(const SettingsVersionTapTarget(), [
      calculatorProvider.overrideWith(() => fakeCalculator),
      historyPagedProvider.overrideWith(() => fakeHistory),
      testDataServiceProvider.overrideWith((ref) {
        fakeTestDataService = _FakeTestDataService(ref);
        return fakeTestDataService;
      }),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await _openHiddenTools(tester);
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.button'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.code'),
      ),
      _todayCode(),
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.submit.button'),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(
        find.byKey(const ValueKey<String>('settings.version.tapTarget')),
      ),
      listen: false,
    );

    expect(fakeTestDataService.enablePremiumAndSeedCalls, 1);
    expect(container.read(appRefreshProvider), 1);
    expect(fakeHistory.refreshCalls, 1);
    expect(fakeCalculator.initCalls, 1);
    expect(fakeCalculator.submitCalls, 1);
    expect(
      find.text(
        lookupAppLocalizations(const Locale('en')).testDataSeededMessage,
      ),
      findsOneWidget,
    );
  });

  testWidgets('can preview renewal feedback sheet from hidden tools', (
    tester,
  ) async {
    final fakeCalculator = FakeCalculatorNotifier();
    final fakeHistory = _FakeHistoryPagedNotifier();

    final db = await tester.pumpApp(const SettingsVersionTapTarget(), [
      calculatorProvider.overrideWith(() => fakeCalculator),
      historyPagedProvider.overrideWith(() => fakeHistory),
      testDataServiceProvider.overrideWith((ref) => _FakeTestDataService(ref)),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await _openHiddenTools(tester);

    await _revealHiddenToolButton(
      tester,
      'settings.testData.previewCancelFeedback.button',
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>(
          'settings.testData.previewCancelFeedback.button',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        lookupAppLocalizations(const Locale('en')).cancelFeedbackPromptTitle,
      ),
      findsOneWidget,
    );
  });

  testWidgets('can show whats new sheet from hidden tools', (tester) async {
    final fakeCalculator = FakeCalculatorNotifier();
    final fakeHistory = _FakeHistoryPagedNotifier();

    final db = await tester.pumpApp(const SettingsVersionTapTarget(), [
      calculatorProvider.overrideWith(() => fakeCalculator),
      historyPagedProvider.overrideWith(() => fakeHistory),
      testDataServiceProvider.overrideWith((ref) => _FakeTestDataService(ref)),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await _openHiddenTools(tester);

    await _revealHiddenToolButton(
      tester,
      'settings.testData.showWhatsNew.button',
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.showWhatsNew.button'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New: Client Pricing'), findsOneWidget);
    expect(find.text('Start free trial'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(fakeAnalytics.lastName, 'whats_new_shown');
    expect(fakeAnalytics.lastParams?['wn_id'], 'pricing_model_2026_05');

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(fakeAnalytics.lastName, 'whats_new_dismissed');
    expect(fakeAnalytics.lastParams?['wn_id'], 'pricing_model_2026_05');
  });

  testWidgets('can enable batch costing from hidden tools', (tester) async {
    final fakeCalculator = FakeCalculatorNotifier();
    final fakeHistory = _FakeHistoryPagedNotifier();

    final db = await tester.pumpApp(const SettingsVersionTapTarget(), [
      calculatorProvider.overrideWith(() => fakeCalculator),
      historyPagedProvider.overrideWith(() => fakeHistory),
      testDataServiceProvider.overrideWith((ref) => _FakeTestDataService(ref)),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await _openHiddenTools(tester);

    await _revealHiddenToolButton(
      tester,
      'settings.testData.enableBatchCosting.button',
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enableBatchCosting.button'),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(
        find.byKey(const ValueKey<String>('settings.version.tapTarget')),
      ),
      listen: false,
    );

    expect(container.read(batchCostingEnabledProvider), isTrue);
  });
}
