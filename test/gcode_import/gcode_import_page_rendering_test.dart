import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';
import 'gcode_import_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupTest();
  });

  testWidgets('renders import flow and logs analytics', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(const GCodeImportPage(source: 'calculator'));

    expect(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
      findsOneWidget,
    );
    expect(analytics.eventNames, contains('gcode_import_opened'));
  });

  testWidgets('logs started once and abandoned on dispose', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(const GCodeImportPage(source: 'calculator'), [
      gcodeImportFilePickerProvider.overrideWithValue(NullPicker()),
    ]);

    final pickButton = find.byKey(
      const ValueKey<String>('gcode_import.select_file.button'),
    );
    await tester.tap(pickButton);
    await tester.pumpAndSettle();
    await tester.tap(pickButton);
    await tester.pumpAndSettle();

    expect(
      analytics.events.where((event) => event.name == 'gcode_import_started'),
      hasLength(1),
    );
    expect(
      analytics.events
          .singleWhere((event) => event.name == 'gcode_import_started')
          .params!['source'],
      'calculator',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(analytics.eventNames, contains('gcode_import_abandoned'));
  });

  testWidgets('logs picker cancelled when single picker returns null', (
    tester,
  ) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(const GCodeImportPage(source: 'calculator'), [
      gcodeImportFilePickerProvider.overrideWithValue(NullPicker()),
    ]);

    await tester.tap(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
    );
    await tester.pumpAndSettle();

    expect(analytics.eventNames, contains('gcode_picker_cancelled'));
    expect(
      analytics.eventNames,
      isNot(contains('gcode_flow_diverted_to_batch')),
    );
    expect(
      analytics.events
          .singleWhere((event) => event.name == 'gcode_picker_cancelled')
          .params,
      {'source': 'calculator'},
    );
  });

  testWidgets('logs flow diverted to batch on multi-file pick', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(const GCodeImportPage(source: 'calculator'), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportFilePickerProvider.overrideWithValue(
        FakePicker([pickedFile('a.gcode'), pickedFile('b.gcode')]),
      ),
    ]);

    await tester.tap(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
    );
    await tester.pump();

    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_flow_diverted_to_batch',
      ),
      hasLength(1),
    );
    expect(
      analytics.events.where((event) => event.name == 'batch_started'),
      hasLength(1),
    );
    expect(
      analytics.events
          .singleWhere((event) => event.name == 'gcode_flow_diverted_to_batch')
          .params,
      {'source': 'calculator'},
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(analytics.eventNames, isNot(contains('gcode_import_abandoned')));
  });

  testWidgets('diverted flow clears abandon tracking in analytics facade', (
    tester,
  ) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    AppAnalytics.resetGcodeImportTrackingForTests();
    await AppAnalytics.gcodeImportOpened();
    await AppAnalytics.gcodeFlowDivertedToBatch(source: 'calculator');
    await AppAnalytics.gcodeImportAbandoned();

    expect(analytics.eventNames, contains('gcode_flow_diverted_to_batch'));
    expect(analytics.eventNames, isNot(contains('gcode_import_abandoned')));
  });

  testWidgets('does not divert on single file pick', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(const GCodeImportPage(source: 'calculator'), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportFilePickerProvider.overrideWithValue(
        FakePicker([pickedFile('a.gcode')]),
      ),
    ]);

    await tester.tap(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
    );
    await tester.pump();

    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_flow_diverted_to_batch',
      ),
      isEmpty,
    );
  });

  testWidgets('premium users can access the import flow', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
    ]);

    expect(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
      findsOneWidget,
    );
  });
}
