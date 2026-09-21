import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/purchases/customer_center_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/components/settings_customer_center_section.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import '../helpers/helpers.dart';
import 'settings_page_test_support.dart';

class _FakeCustomerCenterPresenter implements CustomerCenterPresenter {
  _FakeCustomerCenterPresenter({this.errorOnFirstCall = false, this.timeline});

  final bool errorOnFirstCall;
  final calls = <void>[];
  final completer = Completer<void>();
  final List<String>? timeline;

  @override
  Future<void> present() async {
    timeline?.add('present');
    calls.add(null);
    if (errorOnFirstCall && calls.length == 1) {
      throw StateError('failed');
    }
    await completer.future;
  }
}

class _RecordingAnalytics implements AnalyticsService {
  final events = <String>[];
  final paramsByEvent = <String, Map<String, Object>?>{};

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    events.add(name);
    paramsByEvent[name] = params;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setupTest);

  testWidgets('logs customer center action before presentation', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final analytics = _RecordingAnalytics();
    final original = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = original);
    final timeline = <String>[];
    final presenter = _FakeCustomerCenterPresenter(timeline: timeline);
    AppAnalytics.service = _RecordingAnalyticsWithTimeline(analytics, timeline);
    await tester.pumpApp(const SettingsCustomerCenterSection(), [
      customerCenterPresenterProvider.overrideWithValue(presenter),
    ]);
    await tester.tap(
      find.byKey(const ValueKey<String>('settings.customer-center.title')),
    );
    await tester.pump();
    expect(timeline, ['customer_center_opened', 'present']);
    expect(analytics.paramsByEvent['customer_center_opened'], {
      'source': 'settings',
    });
    presenter.completer.complete();
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Settings page exposes entry for free users on mobile', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final presenter = _FakeCustomerCenterPresenter();
    final settingsRepo = FakeSettingsRepository();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      customerCenterPresenterProvider.overrideWithValue(presenter),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const NoopLogSink()),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);
    settingsRepo.emit(GeneralSettingsModel.initial());
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byKey(const ValueKey<String>('settings.customer-center.section')),
      find.byType(ListView),
      const Offset(0, -300),
    );

    expect(
      find.byKey(const ValueKey<String>('settings.customer-center.section')),
      findsOneWidget,
    );
    expect(find.text('Manage purchases'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Settings page exposes entry for premium users on mobile', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final settingsRepo = FakeSettingsRepository();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(true),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const NoopLogSink()),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);
    settingsRepo.emit(GeneralSettingsModel.initial());
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byKey(const ValueKey<String>('settings.customer-center.section')),
      find.byType(ListView),
      const Offset(0, -300),
    );

    expect(
      find.byKey(const ValueKey<String>('settings.customer-center.section')),
      findsOneWidget,
    );
    expect(find.text('Manage purchases'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('settings.premium.title')),
      findsNothing,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('does not render on web or unsupported platforms', (
    tester,
  ) async {
    expect(
      customerCenterSupportedPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      customerCenterSupportedPlatform(platform: TargetPlatform.macOS),
      isFalse,
    );
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await tester.pumpApp(const SettingsCustomerCenterSection());

    expect(
      find.byKey(const ValueKey<String>('settings.customer-center.section')),
      findsNothing,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('disables while busy and refreshes after successful return', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final presenter = _FakeCustomerCenterPresenter();
    final container = await tester.pumpAppWithContainer(
      const SettingsCustomerCenterSection(),
      overrides: [customerCenterPresenterProvider.overrideWithValue(presenter)],
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.customer-center.title')),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<ListTile>(find.byType(ListTile)).onTap, isNull);
    expect(container.read(appRefreshProvider), 0);

    presenter.completer.complete();
    await tester.pumpAndSettle();
    expect(container.read(appRefreshProvider), 1);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('shows localized retry after presentation failure', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final presenter = _FakeCustomerCenterPresenter(errorOnFirstCall: true);
    final container = await tester.pumpAppWithContainer(
      const SettingsCustomerCenterSection(),
      overrides: [customerCenterPresenterProvider.overrideWithValue(presenter)],
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.customer-center.title')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not open purchase management. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(container.read(appRefreshProvider), 0);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(presenter.calls, hasLength(2));
    presenter.completer.complete();
    await tester.pumpAndSettle();
    expect(container.read(appRefreshProvider), 1);
    debugDefaultTargetPlatformOverride = null;
  });
}

class _RecordingAnalyticsWithTimeline implements AnalyticsService {
  _RecordingAnalyticsWithTimeline(this.delegate, this.timeline);
  final _RecordingAnalytics delegate;
  final List<String> timeline;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    timeline.add(name);
    await delegate.logEvent(name, params: params);
  }
}
