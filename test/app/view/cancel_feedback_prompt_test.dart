import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';

import '../../../test_support/fake_purchases_gateway.dart';
import '../../helpers/lower_level_test_fakes.dart';
import 'app_page_test_support.dart';

class _AnalyticsEvent {
  final String name;
  final Map<String, Object>? params;
  _AnalyticsEvent(this.name, this.params);
}

class _FakeAnalytics implements AnalyticsService {
  final List<_AnalyticsEvent> events = [];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    events.add(_AnalyticsEvent(name, params));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAnalytics analytics;
  late FakeCalculatorNotifier calculatorNotifier;

  setUpAll(bootstrapAppPageTests);

  setUp(() {
    analytics = _FakeAnalytics();
    AppAnalytics.service = analytics;
    AppAnalytics.resetGcodeImportTrackingForTests();
    calculatorNotifier = FakeCalculatorNotifier();
  });


  testWidgets('shows cancel feedback prompt once and logs dismissal', (
    tester,
  ) async {
    seedAppPagePrefs(
      runCount: 0,
      calculationCount: 3,
      hasUsedGcodeImport: true,
      hideProPromotions: true,
    );

    final gateway = FakePurchasesGateway(canceledTrialUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(
      find.text('Looks like you turned off renewal. Mind telling me why?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(analytics.events.last.name, 'trial_cancel_feedback_dismissed');
    expect(analytics.events.last.params?['platform'], 'play_store');
    expect(analytics.events.last.params?['entitlement_type'], 'trial');
    expect(analytics.events.last.params?['calculation_count_bucket'], '2_4');
    expect(analytics.events.last.params?['has_used_gcode_import'], 1);
    expect(analytics.events.last.params?['has_saved_history'], 0);

    await pumpAppPage(
      tester,
      FakePurchasesGateway(canceledTrialUser()),
      calculatorNotifier,
    );
    await settleAppPage(tester);

    expect(
      find.text('Looks like you turned off renewal. Mind telling me why?'),
      findsNothing,
    );
  });

  testWidgets('submits selected cancel feedback reason', (tester) async {
    seedAppPagePrefs(runCount: 0, calculationCount: 1, hideProPromotions: true);

    await pumpAppPage(
      tester,
      FakePurchasesGateway(canceledTrialUser(daysIntoTrial: 2)),
      calculatorNotifier,
    );
    await settleAppPage(tester);

    await tester.tap(find.text('Too expensive'));
    await tester.pump();
    await tester.tap(find.text('Send feedback'));
    await tester.pumpAndSettle();

    expect(analytics.events.last.name, 'trial_cancel_feedback_submitted');
    expect(analytics.events.last.params?['reason'], 'too_expensive');
    expect(analytics.events.last.params?['calculation_count_bucket'], '1');
    expect(analytics.events.last.params?['has_used_gcode_import'], 0);
  });

  testWidgets('shows generic renewal copy for canceled subscriptions', (
    tester,
  ) async {
    seedAppPagePrefs(runCount: 0, hideProPromotions: true);

    await pumpAppPage(
      tester,
      FakePurchasesGateway(canceledSubscriptionUser()),
      calculatorNotifier,
    );
    await settleAppPage(tester);

    expect(
      find.text('Looks like you turned off renewal. Mind telling me why?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(analytics.events.last.name, 'trial_cancel_feedback_dismissed');
    expect(analytics.events.last.params?['entitlement_type'], 'subscription');
    expect(analytics.events.last.params?['days_into_trial'], 0);
  });
}
