import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';

import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart' show FakePaywallPresenter;
import 'settings_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('settings premium card opens paywall for free users', (
    tester,
  ) async {
    final settingsRepo = FakeSettingsRepository();
    final paywallPresenter = FakePaywallPresenter();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      appLogSinkProvider.overrideWithValue(const NoopLogSink()),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);

    settingsRepo.emit(GeneralSettingsModel.initial());

    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byKey(const ValueKey<String>('settings.premium.button')),
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('settings.premium.button')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.premium.button')),
    );
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 1);
    expect(paywallPresenter.lastOfferingId, 'pro');
    expect(paywallPresenter.lastTriggerFeature, 'settings_premium_card');
    expect(paywallPresenter.lastPurchaseSource, 'settings');
    expect(paywallPresenter.lastSource, 'settings');
  });

  testWidgets('printer add action opens AddPrinter dialog', (tester) async {
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
      find.byKey(const ValueKey<String>('settings.printers.add.button')),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.printers.add.button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.printers.name.input')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.printers.bedSize.input')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.printers.wattage.input')),
      findsOneWidget,
    );
  });
}
