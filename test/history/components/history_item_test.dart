import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/history/components/history_item.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

class _RecordingLogSink extends AppLogSink {
  final List<AppLogEvent> events = [];

  @override
  void log(AppLogEvent event) {
    events.add(event);
  }
}

HistoryModel _model() {
  return HistoryModel(
    name: 'Multi Material Benchy',
    totalCost: 42.5,
    riskCost: 3.5,
    filamentCost: 25.0,
    electricityCost: 7.0,
    labourCost: 8.0,
    date: DateTime.utc(2024, 1, 3),
    printer: 'Prusa MK4',
    material: 'PLA',
    weight: 123,
    timeHours: '06:20',
    materialUsages: [
      {'materialId': 'pla-red', 'materialName': 'PLA Red', 'weightGrams': 75},
      {'materialName': 'Support', 'weightGrams': 48},
    ],
  );
}

HistoryModel _singleMaterialSnapshotModel() {
  return HistoryModel(
    name: 'Single Snapshot Benchy',
    totalCost: 14.11,
    riskCost: 1.41,
    filamentCost: 8.19,
    electricityCost: 1.23,
    labourCost: 3.28,
    date: DateTime.utc(2024, 1, 4),
    printer: 'Prusa MK4',
    material: 'PLA Black',
    weight: 123,
    timeHours: '01:45',
    materialUsages: const [
      {
        'materialId': 'pla-black',
        'materialName': 'PLA Black',
        'costPerKg': 0,
        'weightGrams': 123,
      },
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('renders costs, summary, and breakdown labels', (tester) async {
    await tester.pumpApp(HistoryItem(dbKey: 'history-1', data: _model()), [
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value([
          const MaterialModel(
            id: 'pla-red',
            name: 'PLA',
            cost: '25',
            color: 'Red',
            weight: '1000',
            archived: false,
          ),
        ]),
      ),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('Multi Material Benchy'), findsOneWidget);
    expect(find.text('03 Jan 2024'), findsOneWidget);
    expect(find.text('0.12 kg • 6h 20m • Prusa MK4 • PLA'), findsOneWidget);
    expect(find.text('42.50'), findsOneWidget);
    expect(find.text('3.50'), findsOneWidget);
    expect(find.text('25.00'), findsOneWidget);
    expect(find.text('7.00'), findsOneWidget);
    expect(find.text('8.00'), findsOneWidget);

    await tester.tap(
      find.text(
        lookupAppLocalizations(const Locale('en')).materialBreakdownLabel,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PLA (Red)'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('75g'), findsOneWidget);
    expect(find.text('48g'), findsOneWidget);
  });

  testWidgets(
    'renders_single_material_filament_cost_from_stored_snapshot_not_material_usage',
    (tester) async {
      await tester.pumpApp(
        HistoryItem(
          dbKey: 'history-single',
          data: _singleMaterialSnapshotModel(),
        ),
        [
          materialsStreamProvider.overrideWith(
            (ref) => Stream.value([
              const MaterialModel(
                id: 'pla-black',
                name: 'PLA',
                cost: '99',
                color: 'Black',
                weight: '1000',
                archived: false,
              ),
            ]),
          ),
        ],
      );

      await tester.pumpAndSettle();

      expect(find.text('Single Snapshot Benchy'), findsOneWidget);
      expect(find.text('8.19'), findsOneWidget);

      await tester.tap(
        find.text(
          lookupAppLocalizations(const Locale('en')).materialBreakdownLabel,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PLA (Black)'), findsOneWidget);
      expect(find.text('123g'), findsOneWidget);
      expect(find.text('8.19'), findsOneWidget);
    },
  );

  testWidgets('overflow menu shows load export and delete actions', (
    tester,
  ) async {
    await tester.pumpApp(HistoryItem(dbKey: 'history-1', data: _model()));

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyLoadAction),
      findsOneWidget,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).exportButton),
      findsOneWidget,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).deleteButton),
      findsOneWidget,
    );
  });

  testWidgets('batch quote hides load action', (tester) async {
    final model = _model().copyWith(batchQuote: true);
    await tester.pumpApp(HistoryItem(dbKey: 'history-1', data: model));

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyLoadAction),
      findsNothing,
    );
  });

  testWidgets('overflow button keeps strong contrast and tap target', (
    tester,
  ) async {
    await tester.pumpApp(HistoryItem(dbKey: 'history-1', data: _model()));

    final popupMenu = tester.widget<PopupMenuButton<dynamic>>(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    final trigger = popupMenu.icon as SizedBox;
    final icon = (trigger.child as Center).child as Icon;

    expect(icon.icon, Icons.more_horiz);
    expect(icon.color, ICON_PRIMARY);
    expect(trigger.width, 44);
    expect(trigger.height, 44);
  });

  testWidgets('load action forwards history entry to calculator', (
    tester,
  ) async {
    final fakeCalculator = FakeCalculatorNotifier();
    final db = await tester.pumpApp(
      HistoryItem(dbKey: 'history-1', data: _model()),
      [calculatorProvider.overrideWith(() => fakeCalculator)],
    );
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(lookupAppLocalizations(const Locale('en')).historyLoadAction),
    );
    await tester.pumpAndSettle();

    expect(fakeCalculator.loadFromHistoryCalls, 1);
    expect(fakeCalculator.lastLoadedHistory?.key, 'history-1');
    expect(
      fakeCalculator.lastLoadedHistory?.model.name,
      'Multi Material Benchy',
    );
  });

  testWidgets('export action shows success snackbar', (tester) async {
    var exportCalls = 0;
    List<HistoryModel> exportedItems = [];
    String? capturedHeader;
    String? capturedShareText;

    Future<void> exportCsv(
      List<HistoryModel> items, {
      required String csvHeader,
      required String shareText,
    }) async {
      exportCalls += 1;
      exportedItems = items;
      capturedHeader = csvHeader;
      capturedShareText = shareText;
    }

    final db = await tester.pumpApp(
      HistoryItem(dbKey: 'history-1', data: _model(), exportCsv: exportCsv),
    );
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(lookupAppLocalizations(const Locale('en')).exportButton),
    );
    await tester.pumpAndSettle();

    expect(exportCalls, 1);
    expect(exportedItems.single.name, 'Multi Material Benchy');
    expect(
      capturedHeader,
      lookupAppLocalizations(const Locale('en')).historyCsvHeader,
    );
    expect(
      capturedShareText,
      lookupAppLocalizations(const Locale('en')).historyExportShareText,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).exportSuccess),
      findsOneWidget,
    );
  });

  testWidgets('export action shows failure snackbar', (tester) async {
    final sink = _RecordingLogSink();
    final db = await tester.pumpApp(
      HistoryItem(
        dbKey: 'history-2',
        data: _model(),
        exportCsv: (_, {required csvHeader, required shareText}) async {
          throw StateError('boom');
        },
      ),
      [appLogSinkProvider.overrideWithValue(sink)],
    );
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(lookupAppLocalizations(const Locale('en')).exportButton),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(sink.events, hasLength(1));
    expect(sink.events.single.message, 'History export failed');
    expect(sink.events.single.category, AppLogCategory.ui);
    expect(sink.events.single.context['exportType'], 'job');
    expect(sink.events.single.error, isA<StateError>());
    expect((sink.events.single.error as StateError).message, 'boom');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('delete action calls delete handler after confirmation', (
    tester,
  ) async {
    var deletedKey = '';

    final db = await tester.pumpApp(
      HistoryItem(
        dbKey: 'history-1',
        data: _model(),
        deleteHistoryEntry: (ref, dbKey) async {
          deletedKey = dbKey;
        },
      ),
    );
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(lookupAppLocalizations(const Locale('en')).deleteButton).first,
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(
          TextButton,
          lookupAppLocalizations(const Locale('en')).deleteButton,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(deletedKey, 'history-1');
  });
}
