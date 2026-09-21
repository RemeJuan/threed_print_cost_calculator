import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  _FakeCustomerCenterPresenter({this.errorOnFirstCall = false});

  final bool errorOnFirstCall;
  final calls = <void>[];
  final completer = Completer<void>();

  @override
  Future<void> present() async {
    calls.add(null);
    if (errorOnFirstCall && calls.length == 1) {
      throw StateError('failed');
    }
    await completer.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setupTest);

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
