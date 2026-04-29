import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/work_costs_form.dart';

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
  String pricingMarkupPercent = '',
  String pricingSetupFee = '',
  String pricingRoundingMode = 'none',
}) {
  return GeneralSettingsModel(
    electricityCost: electricityCost,
    wattage: wattage,
    activePrinter: activePrinter,
    selectedMaterial: selectedMaterial,
    wearAndTear: wearAndTear,
    failureRisk: failureRisk,
    labourRate: labourRate,
    pricingMarkupPercent: pricingMarkupPercent,
    pricingSetupFee: pricingSetupFee,
    pricingRoundingMode: pricingRoundingMode,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  group('WorkCostsSettings', () {
    testWidgets('shows a placeholder while waiting for settings', (
      tester,
    ) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      expect(find.byType(TextFormField), findsNothing);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byType(DropdownButtonFormField<PricingRoundingMode>), findsOneWidget);
    });

    testWidgets('persists wear and tear after debounce', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.enterText(
        _field('settings.workCost.wearAndTear.input'),
        '0.15',
      );
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();

      expect(repo.savedSettings, hasLength(1));
      expect(repo.savedSettings.single.wearAndTear, '0.15');
    });

    testWidgets('persists failure risk after debounce', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.enterText(
        _field('settings.workCost.failureRisk.input'),
        '0.08',
      );
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();

      expect(repo.savedSettings, hasLength(1));
      expect(repo.savedSettings.single.failureRisk, '0.08');
    });

    testWidgets('persists labour rate after debounce', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.enterText(
        _field('settings.workCost.labourRate.input'),
        '24.5',
      );
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();

      expect(repo.savedSettings, hasLength(1));
      expect(repo.savedSettings.single.labourRate, '24.5');
    });

    testWidgets('persists pricing markup after debounce', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.enterText(
        _field('settings.workCost.pricingMarkup.input'),
        '12.5',
      );
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();

      expect(repo.savedSettings, hasLength(1));
      expect(repo.savedSettings.single.pricingMarkupPercent, '12.5');
    });

    testWidgets('persists pricing setup fee after debounce', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.enterText(
        _field('settings.workCost.pricingSetupFee.input'),
        '3.75',
      );
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();

      expect(repo.savedSettings, hasLength(1));
      expect(repo.savedSettings.single.pricingSetupFee, '3.75');
    });

    testWidgets('persists pricing rounding mode', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey<String>('settings.workCost.pricingRounding.input')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ends in .99').last);
      await tester.pumpAndSettle();

      expect(repo.savedSettings, hasLength(1));
      expect(repo.savedSettings.single.pricingRoundingMode, '.99');
    });

    testWidgets('does not save invalid work cost input', (tester) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(GeneralSettingsModel.initial());
      await tester.pump();

      await tester.enterText(
        _field('settings.workCost.wearAndTear.input'),
        'abc',
      );
      await tester.enterText(
        _field('settings.workCost.failureRisk.input'),
        'abc',
      );
      await tester.enterText(
        _field('settings.workCost.labourRate.input'),
        'abc',
      );
      await tester.enterText(
        _field('settings.workCost.pricingMarkup.input'),
        'abc',
      );
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();

      expect(repo.savedSettings, isEmpty);
    });

    testWidgets('keeps a focused field from being overwritten by updates', (
      tester,
    ) async {
      final repo = _FakeSettingsRepository();
      final db = await tester.pumpApp(const WorkCostsSettings(), [
        settingsRepositoryProvider.overrideWithValue(repo),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(repo.dispose);

      repo.emit(
        _settings(wearAndTear: '0.10', failureRisk: '0.05', labourRate: '20'),
      );
      await tester.pump();

      final labourField = _field('settings.workCost.labourRate.input');
      await tester.tap(labourField);
      await tester.pump();
      await tester.enterText(labourField, '27.5');
      await tester.pump();

      repo.emit(
        _settings(
          wearAndTear: '0.20',
          failureRisk: '0.06',
          labourRate: '30',
          pricingMarkupPercent: '18',
        ),
      );
      await tester.pump();

      expect(
        tester.widget<TextFormField>(labourField).controller!.text,
        '27.5',
      );
      expect(
        tester.widget<TextFormField>(_field('settings.workCost.pricingMarkup.input'))
            .controller!
            .text,
        '18',
      );
    });
  });
}
