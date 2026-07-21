import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';
import 'gcode_import_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupTest();
  });

  testWidgets('primary action emits apply analytics before calculator update', (
    tester,
  ) async {
    final timeline = <String>[];
    final analytics = RecordingTimelineAnalytics(timeline);
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    final fakeCalculator = _FakeCalculatorProvider(timeline);

    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
      calculatorProvider.overrideWith(() => fakeCalculator),
    ]);

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('gcode_import.apply.button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('gcode_import.apply.button')),
    );
    await tester.pump();

    await tester.pump(const Duration(seconds: 3));
    expect(
      timeline,
      equals([
        'analytics:gcode_import_opened',
        'analytics:gcode_apply_to_calculator',
        'calculator:applyImportedValues',
        'analytics:gcode_import_success',
        'analytics:gcode_flow_completed',
      ]),
    );

    final applyEvent = analytics.events.firstWhere(
      (event) => event.name == 'gcode_apply_to_calculator',
    );
    expect(applyEvent.params, containsPair('slicer', 'prusaSlicer'));
    expect(applyEvent.params, containsPair('parse_status', 'success'));
    expect(applyEvent.params, containsPair('file_size_bucket', '<1MB'));

    expect(fakeCalculator.calls, hasLength(1));
    expect(
      fakeCalculator.calls.single.estimatedDuration,
      const Duration(minutes: 10),
    );
    expect(fakeCalculator.calls.single.filamentWeightGrams, 10);
    safeBotToastCleanAll();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });

  testWidgets('primary action stops after apply event when calculator throws', (
    tester,
  ) async {
    final timeline = <String>[];
    final analytics = RecordingTimelineAnalytics(timeline);
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
      calculatorProvider.overrideWith(
        () => _ThrowingCalculatorProvider(timeline),
      ),
    ]);

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('gcode_import.apply.button')),
    );
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    final errors = <Object>[];
    FlutterError.onError = (details) {
      errors.add(details.exception);
    };
    try {
      await tester.tap(
        find.byKey(const ValueKey<String>('gcode_import.apply.button')),
      );
      await tester.pump();
    } finally {
      FlutterError.onError = originalOnError;
    }

    expect(
      timeline,
      equals([
        'analytics:gcode_import_opened',
        'analytics:gcode_apply_to_calculator',
        'calculator:applyImportedValues',
      ]),
    );
    expect(errors, contains(isA<StateError>()));

    expect(analytics.eventNames, isNot(contains('gcode_import_success')));
    expect(analytics.eventNames, isNot(contains('gcode_flow_completed')));
    safeBotToastCleanAll();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}

class _FakeCalculatorProvider extends CalculatorProvider {
  _FakeCalculatorProvider(this.timeline);

  final List<String> timeline;
  final List<_ApplyCall> calls = [];

  @override
  CalculatorState build() => CalculatorState();

  @override
  void applyImportedValues({
    Duration? estimatedDuration,
    double? filamentWeightGrams,
  }) {
    timeline.add('calculator:applyImportedValues');
    calls.add(
      _ApplyCall(
        estimatedDuration: estimatedDuration,
        filamentWeightGrams: filamentWeightGrams,
      ),
    );
  }
}

class _ThrowingCalculatorProvider extends CalculatorProvider {
  _ThrowingCalculatorProvider(this.timeline);

  final List<String> timeline;

  @override
  CalculatorState build() => CalculatorState();

  @override
  void applyImportedValues({
    Duration? estimatedDuration,
    double? filamentWeightGrams,
  }) {
    timeline.add('calculator:applyImportedValues');
    throw StateError('calculator failed');
  }
}

class RecordingTimelineAnalytics extends RecordingAnalytics {
  RecordingTimelineAnalytics(this.timeline);

  final List<String> timeline;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    timeline.add('analytics:$name');
    await super.logEvent(name, params: params);
  }
}

class _ApplyCall {
  _ApplyCall({this.estimatedDuration, this.filamentWeightGrams});

  final Duration? estimatedDuration;
  final double? filamentWeightGrams;
}
