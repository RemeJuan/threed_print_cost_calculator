import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';

import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart';

class _NoopLogSink extends AppLogSink {
  const _NoopLogSink();

  @override
  void log(AppLogEvent event) {}
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({GeneralSettingsModel? initialSettings})
    : _settings = initialSettings ?? GeneralSettingsModel.initial();

  final _controller = StreamController<GeneralSettingsModel>.broadcast();
  GeneralSettingsModel _settings;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;

  @override
  Stream<GeneralSettingsModel> watchSettings() => _controller.stream;

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {
    _settings = settings;
    _controller.add(settings);
  }

  void emit(GeneralSettingsModel settings) {
    _settings = settings;
    _controller.add(settings);
  }

  Future<void> dispose() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('free users see general and printers settings content', (
    tester,
  ) async {
    final settingsRepo = _FakeSettingsRepository();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);

    settingsRepo.emit(GeneralSettingsModel.initial());

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.general.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.general.body')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.printers.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.section')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.workCost.section')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.printers.add.button')),
      findsOneWidget,
    );
    await tester.dragUntilVisible(
      find.byKey(const ValueKey<String>('settings.premium.title')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(
      find.byKey(const ValueKey<String>('settings.premium.title')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.premium.button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.add.button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('support.version.tapTarget')),
      findsNothing,
    );
  });

  testWidgets('free users at printer limit see disabled add action', (
    tester,
  ) async {
    final settingsRepo = _FakeSettingsRepository();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      printersStreamProvider.overrideWith(
        (ref) => Stream.value([
          PrinterModel(
            id: 'p1',
            name: 'P1',
            bedSize: '220 x 220',
            wattage: '120',
            archived: false,
          ),
          PrinterModel(
            id: 'p2',
            name: 'P2',
            bedSize: '220 x 220',
            wattage: '120',
            archived: false,
          ),
        ]),
      ),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);

    settingsRepo.emit(GeneralSettingsModel.initial());

    await tester.pumpAndSettle();

    final addButton = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('settings.printers.add.button')),
    );
    expect(addButton.onPressed, isNull);
    expect(
      find.text(
        'You can save up to 2 printers on Free. Upgrade to Premium for unlimited printers.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'premium users see printers and work cost sections but not materials',
    (tester) async {
      final settingsRepo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const SettingsPage(), [
        isPremiumProvider.overrideWithValue(true),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(settingsRepo.dispose);

      settingsRepo.emit(GeneralSettingsModel.initial());

      await tester.pumpAndSettle();

      // Visible initially (top of page)
      final generalTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey<String>('settings.general.section')),
      );
      final workCostsTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey<String>('settings.workCost.section')),
      );

      // Printers section is off-screen after emit (WorkCosts form is tall).
      // SliverChildListDelegate only builds elements for visible children,
      // so we must scroll to reveal it before checking.
      await tester.dragUntilVisible(
        find.byKey(const ValueKey<String>('settings.printers.section')),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('settings.printers.section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.materials.section')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.workCost.section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.printers.add.button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.premium.title')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.materials.add.button')),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey<String>('settings.workCost.currencySpacing.toggle'),
        ),
        findsOneWidget,
      );
      expect(generalTopLeft.dy, lessThan(workCostsTopLeft.dy));
      expect(workCostsTopLeft.dy, greaterThan(generalTopLeft.dy));
    },
  );

  testWidgets('settings premium card opens paywall for free users', (
    tester,
  ) async {
    final settingsRepo = _FakeSettingsRepository();
    final paywallPresenter = FakePaywallPresenter();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
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

  testWidgets('automatic backup button opens paywall for free users', (
    tester,
  ) async {
    final settingsRepo = _FakeSettingsRepository();
    final paywallPresenter = FakePaywallPresenter();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);

    settingsRepo.emit(GeneralSettingsModel.initial());

    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Schedule automatic backup'),
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Schedule automatic backup'));
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 1);
    expect(paywallPresenter.lastTriggerFeature, 'automatic_backup');
  });

  testWidgets('printer add action opens AddPrinter dialog', (tester) async {
    final settingsRepo = _FakeSettingsRepository();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(true),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
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
