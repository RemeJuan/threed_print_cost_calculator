import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_page.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import '../../helpers/helpers.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockInterfaceSettingsRepository extends Mock
    implements InterfaceSettingsRepository {}

class _RecordedFlutterError {
  _RecordedFlutterError(this.details);

  final FlutterErrorDetails details;
}

void main() {
  setUp(() async {
    await setupTest();
  });

  testWidgets('logs interface visibility toggle changes once after save', (
    tester,
  ) async {
    final analytics = MockAnalyticsService();
    AppAnalytics.service = analytics;
    when(
      () => analytics.logEvent(any(), params: any(named: 'params')),
    ).thenAnswer((_) async {});

    await tester.pumpApp(const InterfaceSettingsPage(), [
      premiumAccessPolicyProvider.overrideWithValue(
        DefaultPremiumAccessPolicy(isPremium: true),
      ),
    ]);

    verifyNever(
      () => analytics.logEvent(
        'interface_visibility_changed',
        params: any(named: 'params'),
      ),
    );

    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    verify(
      () => analytics.logEvent(
        'interface_visibility_changed',
        params: {'setting': 'printer_select', 'visible': 0},
      ),
    ).called(1);
  });

  testWidgets('does not log when save fails', (tester) async {
    final analytics = MockAnalyticsService();
    AppAnalytics.service = analytics;
    when(
      () => analytics.logEvent(any(), params: any(named: 'params')),
    ).thenAnswer((_) async {});

    final failingRepository = MockInterfaceSettingsRepository();
    when(() => failingRepository.updateSettings(any())).thenAnswer((_) async {
      throw Exception('save failed');
    });

    final previousOnError = FlutterError.onError;
    final flutterErrors = <_RecordedFlutterError>[];
    FlutterError.onError = (details) {
      flutterErrors.add(_RecordedFlutterError(details));
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpApp(const InterfaceSettingsPage(), [
      premiumAccessPolicyProvider.overrideWithValue(
        DefaultPremiumAccessPolicy(isPremium: true),
      ),
      interfaceSettingsRepositoryProvider.overrideWithValue(failingRepository),
    ]);

    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    verify(() => failingRepository.updateSettings(any())).called(1);
    expect(
      find.text('Could not save interface settings. Try again.'),
      findsOneWidget,
    );
    expect(flutterErrors, hasLength(1));
    expect(
      flutterErrors.single.details.exception,
      isA<Exception>().having(
        (error) => error.toString(),
        'message',
        'Exception: save failed',
      ),
    );

    verifyNever(
      () => analytics.logEvent(
        'interface_visibility_changed',
        params: any(named: 'params'),
      ),
    );
  });

  testWidgets('does not log on rebuild or initial load', (tester) async {
    final analytics = MockAnalyticsService();
    AppAnalytics.service = analytics;
    when(
      () => analytics.logEvent(any(), params: any(named: 'params')),
    ).thenAnswer((_) async {});

    await tester.pumpApp(const InterfaceSettingsPage(), [
      premiumAccessPolicyProvider.overrideWithValue(
        DefaultPremiumAccessPolicy(isPremium: true),
      ),
    ]);
    await tester.pump();

    verifyNever(
      () => analytics.logEvent(
        'interface_visibility_changed',
        params: any(named: 'params'),
      ),
    );
  });
}
