import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

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
  final savedSettings = <GeneralSettingsModel>[];
  GeneralSettingsModel _settings;

  void emit(GeneralSettingsModel settings) {
    _settings = settings;
    _controller.add(settings);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;

  @override
  Stream<GeneralSettingsModel> watchSettings() => _controller.stream;

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {
    _settings = settings;
    savedSettings.add(settings);
  }

  Future<void> dispose() => _controller.close();
}

Finder _field(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(TextFormField),
  );
}

GeneralSettingsModel _settings({
  String electricityCost = '',
  String wattage = '',
  String activePrinter = '',
  String selectedMaterial = '',
  String wearAndTear = '',
  String failureRisk = '',
  String labourRate = '',
}) {
  return GeneralSettingsModel(
    electricityCost: electricityCost,
    wattage: wattage,
    activePrinter: activePrinter,
    selectedMaterial: selectedMaterial,
    wearAndTear: wearAndTear,
    failureRisk: failureRisk,
    labourRate: labourRate,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  group('GeneralSettings', () {
    testWidgets('persists a valid electricity cost after debounce', (
      tester,
    ) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const GeneralSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.enterText(_field('settings.electricityCost.input'), '0.25');
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();

      expect(repo.savedSettings, hasLength(1));
      expect(repo.savedSettings.single.electricityCost, '0.25');
    });

    testWidgets('ignores invalid electricity cost input', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const GeneralSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.enterText(_field('settings.electricityCost.input'), 'abc');
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();

      expect(repo.savedSettings, isEmpty);
    });

    testWidgets('shows stream updates when the field is unfocused', (
      tester,
    ) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const GeneralSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      repo.emit(_settings(electricityCost: '0.42', wattage: '220'));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .widget<TextFormField>(_field('settings.electricityCost.input'))
            .controller!
            .text,
        '0.42',
      );
      expect(
        tester
            .widget<TextFormField>(_field('settings.generalWattage.input'))
            .controller!
            .text,
        '220',
      );
    });

    testWidgets('does not overwrite a focused field from stream updates', (
      tester,
    ) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const GeneralSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      final field = _field('settings.electricityCost.input');
      await tester.tap(field);
      await tester.pump();
      await tester.enterText(field, '0.31');
      await tester.pump();

      repo.emit(_settings(electricityCost: '0.99', wattage: '200'));
      await tester.pump();
      await tester.pump();

      expect(tester.widget<TextFormField>(field).controller!.text, '0.31');
    });

    testWidgets('renders safe defaults after a stream error', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const GeneralSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emitError(StateError('boom'));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .widget<TextFormField>(_field('settings.electricityCost.input'))
            .controller!
            .text,
        '',
      );
      expect(
        tester
            .widget<TextFormField>(_field('settings.generalWattage.input'))
            .controller!
            .text,
        '',
      );
    });

    testWidgets('persists the hide Pro promotions toggle', (tester) async {
      final repo = _FakeSettingsRepository();
      final prefs = await SharedPreferences.getInstance();
      final db = await tester.pumpApp(const GeneralSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        isPremiumProvider.overrideWithValue(false),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      final toggle = find.byKey(
        const ValueKey<String>('settings.hideProPromotions.toggle'),
      );
      expect(toggle, findsOneWidget);

      await tester.tap(toggle);
      await tester.pump();

      expect(prefs.getBool('hideProPromotions'), isTrue);
    });

    testWidgets('hides the toggle for premium users', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const GeneralSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        isPremiumProvider.overrideWithValue(true),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('settings.hideProPromotions.toggle')),
        findsNothing,
      );
    });
  });
}
