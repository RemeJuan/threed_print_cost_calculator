import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('free users only see general settings content', (tester) async {
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
      findsNothing,
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
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.add.button')),
      findsNothing,
    );
  });

  testWidgets('premium users see printers materials and work cost sections', (
    tester,
  ) async {
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

    expect(
      find.byKey(const ValueKey<String>('settings.printers.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.section')),
      findsOneWidget,
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
      findsOneWidget,
    );
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

  testWidgets('material add action opens MaterialForm dialog', (tester) async {
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

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.materials.add.button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.materials.name.input')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.color.input')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.weight.input')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.cost.input')),
      findsOneWidget,
    );
  });
}
