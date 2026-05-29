import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';

import '../helpers/helpers.dart';

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

Finder _hideProPromotionsToggle() {
  return find.byKey(
    const ValueKey<String>('settings.hideProPromotions.toggle'),
  );
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
    expect(_hideProPromotionsToggle(), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('settings.printers.add.button')),
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
      find.text('Upgrade to Premium to add more printers.'),
      findsOneWidget,
    );
  });

  testWidgets('free user toggle restores persisted enabled state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'hideProPromotions': true});

    final settingsRepo = _FakeSettingsRepository();
    final prefs = await SharedPreferences.getInstance();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);

    settingsRepo.emit(GeneralSettingsModel.initial());

    await tester.pumpAndSettle();

    expect(_hideProPromotionsToggle(), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(_hideProPromotionsToggle()).value,
      isTrue,
    );
    expect(prefs.getBool('hideProPromotions'), isTrue);
  });

  testWidgets('toggling promo visibility updates immediately', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final settingsRepo = _FakeSettingsRepository();
    final prefs = await SharedPreferences.getInstance();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);

    settingsRepo.emit(GeneralSettingsModel.initial());

    await tester.pumpAndSettle();

    await tester.tap(_hideProPromotionsToggle());
    await tester.pump();

    expect(
      tester.widget<SwitchListTile>(_hideProPromotionsToggle()).value,
      isTrue,
    );
    expect(prefs.getBool('hideProPromotions'), isTrue);
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
        find.byKey(const ValueKey<String>('settings.materials.add.button')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.hideProPromotions.toggle')),
        findsNothing,
      );

      final printersTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey<String>('settings.printers.section')),
      );

      expect(generalTopLeft.dy, lessThan(workCostsTopLeft.dy));
      expect(workCostsTopLeft.dy, lessThan(printersTopLeft.dy));
    },
  );

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
