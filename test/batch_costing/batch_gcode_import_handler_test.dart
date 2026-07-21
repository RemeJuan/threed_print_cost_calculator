import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';
import '../gcode_import/gcode_import_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupTest();
  });

  testWidgets('logs picker cancelled when batch picker returns empty', (
    tester,
  ) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(const BatchGCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportFilePickerProvider.overrideWithValue(NullPicker()),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(analytics.eventNames, contains('gcode_picker_cancelled'));
    expect(
      analytics.events
          .singleWhere((event) => event.name == 'gcode_picker_cancelled')
          .params,
      {'source': 'batch_gcode_import'},
    );
  });
}
